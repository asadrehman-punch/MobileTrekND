//
//  ViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/9/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD
import SharkORM

class ViewController: BaseViewController {
    
    @IBOutlet weak var programField: UITextField!
    @IBOutlet weak var partField: UITextField!
    @IBOutlet weak var pinField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var programIcon: UIImageView!
    @IBOutlet weak var partIcon: UIImageView!
    @IBOutlet weak var pinIcon: UIImageView!
    @IBOutlet weak var poweredByLogo: UIImageView!
    @IBOutlet weak var rememberLoginButton: UIButton!
    @IBOutlet weak var rememberLoginLabel: ButtonBindingLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var updateButton: UIButton!
    
    fileprivate var globalPlatform: Platform = Platform.shared()
    fileprivate var activeField: UITextField? = nil
    fileprivate var shouldRememberLogin: Bool = false
    fileprivate var isOfflineTestingAvailable: Bool = false
    fileprivate var progressHud: MBProgressHUD? = nil
    
    // MARK: - Overridden functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let defaults = UserDefaults.standard
        
        if CTSKNetworking.connectedToNetwork() {
            commitOfflineBacTest()
        }
        
        isOfflineTestingAvailable = defaults.bool(forKey: "canBacTest")
        
        defaults.removeObject(forKey: "loginSession")
        
        let remLogin = defaults.bool(forKey: "shouldRememberLogin")
        if remLogin {
            rememberLoginButton.setImage(UIImage(named: "buttonOn"), for: UIControl.State())
            shouldRememberLogin = true
        }
        
        defaults.synchronize()
        
        // Add gesture recognizer to hide keyboard if the back view is touched
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        self.view.addGestureRecognizer(tap)
        
        initializeLayout()
        
        updateButton.isHidden = shouldHideUpdateButton(defaults)
        
        // Populate fields if the user selected to remember their login info
        if shouldRememberLogin {
            if let programId = defaults.string(forKey: "globalProgramId") {
                programField.text = programId
            }
            if let partId = defaults.string(forKey: "globalPartId") {
                partField.text = partId
            }
            if let pin = defaults.string(forKey: "globalPin") {
                pinField.text = pin
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden(_:)),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
       // setupColorNavBar()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = Graphics.primaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        
        
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - IBAction Handlers
    
    @IBAction func supportButton_Clicked(_ sender: Any) {
        let supportVC = self.storyboard?.instantiateViewController(withIdentifier: "supportView") as! SupportViewController
        supportVC.isFromLogin = true
        self.navigationController?.pushViewController(supportVC, animated: true)
    }
    
    @IBAction func updateButton_Clicked(_ sender: AnyObject) {
        if let url = URL(string: "itms://itunes.apple.com/us/app/mobiletrek/id1016517488?ls=1&mt=8") {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
        else {
            showStandardAlert("URL Error", message: "Unable to open App Store.")
        }
    }
    
    @IBAction func toggleRememberLogin(_ sender: AnyObject) {
        if !shouldRememberLogin {
            rememberLoginButton.setImage(UIImage(named: "buttonOn"), for: UIControl.State())
            shouldRememberLogin = true
        }
        else {
            rememberLoginButton.setImage(UIImage(named: "buttonOff"), for: UIControl.State())
            shouldRememberLogin = false
        }
    }
    
    @IBAction func submitBtnClick(_ sender: AnyObject) {
        if CTSKNetworking.connectedToNetwork() {
            print("network connected")
            
            submitBtn.isEnabled = false
            
            if programField.text!.isEmpty || partField.text!.isEmpty || pinField.text!.isEmpty {
                showStandardAlert("Oops", message: "Please fill in all 3 fields")
                
                BFLog("User didn't enter valid credentials. 'Please fill in all 3 fields'")
                
                submitBtn.isEnabled = true
            }
            else {
                progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
                progressHud?.label.text = "Logging In"
                
                let date = Date()
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "MM-dd-yyyy HH:mm"
                
                // Set the new session
                let defaults = UserDefaults.standard
                defaults.set(dateFormat.string(from: date), forKey: "loginSession")
                defaults.synchronize()
                
                attemptUserLogin()
            }
        }
        else if isOfflineTestingAvailable {
            let defaults = UserDefaults.standard
            if let baseUrl = defaults.string(forKey: "globalBaseURL"),
                let partId = defaults.string(forKey: "globalPartId"),
                let pin = defaults.string(forKey: "globalPin"),
                let programId = defaults.string(forKey: "globalProgramId") {
                Platform.destroy()
                globalPlatform = Platform.shared()
                
                globalPlatform.baseUrl = baseUrl
                globalPlatform.globalPartId = partId
                globalPlatform.globalPin = pin
                globalPlatform.globalProgramId = programId
                
                globalPlatform.bacDevice = defaults.string(forKey: "BAC_DEVICE") ?? "BACtrack"
                
                if partField.text == globalPlatform.globalPartId
                    && pinField.text == globalPlatform.globalPin
                    && programField.text == globalPlatform.globalProgramId {
                    globalPlatform.alcoholBACTest = true
                    globalPlatform.support = true
                    
//                    let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "mtrekmenu") as! MTrekMenuViewController
//                    self.navigationController?.pushViewController(mtrekmenu, animated: true)
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                }
                else {
                    showStandardAlert("Invalid Login", message: "Please make sure your Program ID, Participant ID, and Pin match the information given to you.")
                }
            }
            else {
                showStandardAlert("Login Error", message: "Offline testing is currently not available due to not enough login information provided.")
            }
        }
        else {
            showStandardAlert("Network Error", message: "Network connection could not be established.")
        }
    }
    
    func dismissKeyboard() {
        activeField?.resignFirstResponder()
    }
    
    @objc func keyboardWasShown(_ notification: Notification) {
        let info = notification.userInfo!
        var kbRect = (info[UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue
        kbRect = view.convert(kbRect, from: nil)
        
        let contentInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: kbRect.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        if let field = activeField {
            var aRect = self.view.frame
            aRect.size.height -= kbRect.height
            if !aRect.contains(field.frame.origin) {
                scrollView.scrollRectToVisible(field.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWasHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func hideKeyboard(_ sender: AnyObject) {
        if programField.isFirstResponder {
            programField.resignFirstResponder()
        }
        else if partField.isFirstResponder {
            partField.resignFirstResponder()
        }
        else if pinField.isFirstResponder {
            pinField.resignFirstResponder()
        }
    }
    
    @IBAction func textFieldDidBeginEditing(_ sender: UITextField) {
        activeField = sender
    }
    
    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        activeField = nil
    }
    
    // MARK: - Private & Helper Functions
    
    private func initializeLayout() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = Graphics.primaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        Graphics.addBorder(view: programField, position: .bottom)
        Graphics.addBorder(view: partField, position: .bottom)
        
        submitBtn.backgroundColor = Graphics.primaryColor
        
        updateButton.backgroundColor = Graphics.primaryColor
        updateButton.setTitleColor(Graphics.progressColor, for: .normal)
        
        rememberLoginLabel.bindingButton = rememberLoginButton
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            numberToolbar.barStyle = .blackTranslucent
            numberToolbar.tintColor = UIColor.white
            numberToolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard(_:)))
            ]
            numberToolbar.sizeToFit()
            
            programField.inputAccessoryView = numberToolbar
            partField.inputAccessoryView = numberToolbar
            pinField.inputAccessoryView = numberToolbar
        }
    }
    
    private func attemptUserLogin() {
        let programIdRequest = NTProgramIDRequest()
        programIdRequest.programId = programField.text!
        programIdRequest.sendRequest { programUrl, programMessage in
            if let program = programUrl {
                self.globalPlatform.baseUrl = program
                
                let loginRequest = NTLoginRequest(baseUrl: program, participantId: self.partField.text!, pin: self.pinField.text!)
                loginRequest.sendRequest({ successful, sobrietyDate, bacDevice, loginMessage in
                    if successful {
                        DispatchQueue.main.async(execute: {
                            BFLog("Login with Program ID: \(self.programField.text!) - Participant ID: \(self.partField.text!)")
                            
                            let optPermsRequest = NTOptpermsRequest(baseUrl: program, participantId: self.partField.text!)
                            optPermsRequest.sendRequest({ successful, message, options in
                                print(options)
                                
                                if message != "success" {
                                    BFLog("OptPerms Error: \(message)")
                                }
                                
                                if successful {
                                    let historyRequest = NTHistoryRequest(baseUrl: program, participantId: self.partField.text!, pin: self.pinField.text!)
                                    historyRequest.sendRequest({ (success, message, checkInStatusHistory, facilityCheckinoutHistory, meetingCheckinoutHistory, bacTestHistory) in
                                        print(options)
                                        self.globalPlatform.bacDevice = bacDevice ?? "BACtrack"
                                        self.globalPlatform.checkInStatusHistory = checkInStatusHistory ?? [CheckInHistory]()
                                        self.globalPlatform.globalCheckInHistory = (options.checkInHistory) //? checkInStatusHistory != nil : false
                                        
                                        self.globalPlatform.globalFacilityCheckInHistory = (options.facilityCheckInHistory) //? facilityCheckinoutHistory != nil : false
                                        self.globalPlatform.checkOutStatusHistory = facilityCheckinoutHistory ?? [FacilityHistory]()
                                        self.globalPlatform.globalMeetingCheckInHistory = (options.meetingCheckInHistory) ? meetingCheckinoutHistory != nil : false
                                        self.globalPlatform.meetingHistory = meetingCheckinoutHistory ?? [MeetingHistory]()
                                        self.globalPlatform.bacTestHistory = bacTestHistory
                                        self.globalPlatform.globalBacTestHistory = (options.bacTestHistory) ? bacTestHistory != nil : false
                                        
                                        self.globalPlatform.support = options.support
                                        self.globalPlatform.nearestCollectionLocations = options.nearestCollectionLocations
                                        self.globalPlatform.alcoholBACTest = options.alcoholBACTest
                                        self.globalPlatform.checkDailyStatus = options.checkDailyStatus
                                        
                                        self.globalPlatform.showBracLevel = options.showBracLevel
                                        self.globalPlatform.showBracResult = options.showBracResult
                                        self.globalPlatform.requireBACConfirmation = options.requireBACConfirmation
                                        
                                        self.globalPlatform.collectionSiteCheckIn = options.collectionSiteCheckIn
                                        self.globalPlatform.collectionSiteCheckOut = options.collectionSiteCheckOut
                                        self.globalPlatform.collectionSiteCheckInLocation = options.collectionSiteCheckInLocation
                                        self.globalPlatform.collectionSiteCheckOutLocation = options.collectionSiteCheckOutLocation
                                        self.globalPlatform.collectionSiteCheckInSelfie = options.collectionSiteCheckInSelfie
                                        self.globalPlatform.collectionSiteCheckOutSelfie = options.collectionSiteCheckOutSelfie
                                        
                                        self.globalPlatform.cocNumber = options.cocNumber
                                        self.globalPlatform.cocLogData = true//options.cocLogData
                                        self.globalPlatform.cocObserved = options.cocObserved
                                        self.globalPlatform.cocFormCheckIn = options.cocFormCheckIn
                                        self.globalPlatform.cocFormCheckOut = options.cocFormCheckOut
                                        self.globalPlatform.cocOptionNumber = options.cocOptionNumber
                                        self.globalPlatform.questAuthorization = options.questAuthorization
                                        
                                        self.globalPlatform.meetingCheckIn = options.meetingCheckIn
                                        self.globalPlatform.meetingCheckOut = options.meetingCheckOut
                                        self.globalPlatform.meetingCheckInName = options.meetingCheckInName
                                        self.globalPlatform.meetingCheckInLocation = options.meetingCheckInLocation
                                        self.globalPlatform.meetingCheckOutLocation = options.meetingCheckOutLocation
                                        self.globalPlatform.meetingCheckInSelfie = options.meetingCheckInSelfie
                                        self.globalPlatform.meetingCheckOutSelfie = options.meetingCheckOutSelfie
                                        self.globalPlatform.meetingCheckInAttendance = options.meetingCheckInAttendance
                                        self.globalPlatform.meetingCheckInSignature = options.meetingCheckInSignature
                                        self.globalPlatform.meetingAttendance = options.meetingAttendance
                                        self.globalPlatform.meetingSignature = options.meetingSignature
                                        
                                        self.globalPlatform.globalSobrietyDate = options.sobrietyDate
                                        self.globalPlatform.globalTopic = options.topic
                                        self.globalPlatform.monitoring = options.monitoring
                                        self.globalPlatform.bacRecognition = options.bacRecognition
                                        self.globalPlatform.cocOptionNumberCheckOut = options.cocOptionNumberCheckOut
                                        self.globalPlatform.cocObservedCheckOut = options.cocObservedCheckOut
                                        self.globalPlatform.cocNumberCheckOut = options.cocNumberCheckOut
                                        self.globalPlatform.survey = options.survey
                                        let defaults = UserDefaults.standard
                                        defaults.set(options.alcoholBACTest, forKey: "canBacTest")
                                        defaults.set(self.globalPlatform.bacDevice, forKey: "BAC_DEVICE")
                                        
                                        if let bracDeviceId = options.breathalyzerId {
                                            defaults.set(bracDeviceId, forKey: "bacTrackDeviceUUID")
                                        }
                                        else {
                                            defaults.removeObject(forKey: "bacTrackDeviceUUID")
                                        }
                                        
                                        defaults.synchronize()
                                        
                                        self.globalPlatform.sobrietyDate = sobrietyDate
                                        
                                        print(options)
                                        
                                        let meetingTypeRequest = NTMeetingTypeRequest(baseUrl: program, participantId: self.partField.text!, pin: self.pinField.text!)
                                        meetingTypeRequest.sendRequest({ meetingActivities, meetingTypeMessage in
                                            if let meetingTypes = meetingActivities {
                                                if meetingTypeMessage != "success" {
                                                    BFLog("MeetingTypeMsg = \(meetingTypeMessage)")
                                                }
                                                
                                                if meetingTypes.count > 0 {
                                                    self.globalPlatform.meetingTypes = meetingTypes
                                                }
                                            }
                                            
                                            self.attemptMeetingCheckInOutClear()
                                            
                                            self.successfulLogin()
                                            
                                            self.progressHud?.hide(animated: true)
                                            self.submitBtn.isEnabled = true
                                            
                                            // Go to mtrekmenu aka tab bar controller
                                            //let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
                                            //self.navigationController?.pushViewController(mtrekmenu, animated: true)
                                            self.loadAvailableController()
                                        })
                                    })
                                }
                                else {
                                    DispatchQueue.main.async(execute: {
                                        self.progressHud?.hide(animated: true)
                                        self.submitBtn.isEnabled = true
                                        
                                        self.showStandardAlert("Program ID Error", message: message)
                                    })
                                    
                                    BFLog("Permission Request Error: \(message)")
                                }
                            })
                        })
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            self.progressHud?.hide(animated: true)
                            self.submitBtn.isEnabled = true
                            
                            self.showStandardAlert("Login Error", message: loginMessage)
                        })
                        
                        BFLog("Login Error: \(loginMessage)")
                    }
                })
            }
            else {
                DispatchQueue.main.async(execute: {
                    self.progressHud?.hide(animated: true)
                    self.submitBtn.isEnabled = true
                    
                    self.showStandardAlert("Program ID Error", message: programMessage)
                })
                
                BFLog("Program ID Error: \(programMessage)")
            }
        }
    }
    
    func loadAvailableController(){
        
        if self.globalPlatform.checkDailyStatus || self.globalPlatform.collectionSiteCheckIn || self.globalPlatform.collectionSiteCheckOut {
            let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "testStatusDash") as! TestStatusDashboardViewController
            self.navigationController?.pushViewController(mtrekmenu, animated: true)
        } else if self.globalPlatform.meetingCheckIn || self.globalPlatform.meetingCheckOut {
            let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "checkInOutDash") as! CheckInOutDashboardViewController
            self.navigationController?.pushViewController(mtrekmenu, animated: true)
        }else if self.globalPlatform.nearestCollectionLocations {
            let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "nearestColSitesView") as! NearestCollectionSitesViewController
            self.navigationController?.pushViewController(mtrekmenu, animated: true)
        }else if self.globalPlatform.alcoholBACTest {
            let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "bacDash") as! BACTestDashboardViewController
            self.navigationController?.pushViewController(mtrekmenu, animated: true)
        }else if self.globalPlatform.support{
            let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "supportView") as! SupportViewController
            self.navigationController?.pushViewController(mtrekmenu, animated: true)
        }else if self.globalPlatform.survey{
            let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
            self.navigationController?.pushViewController(mtrekmenu, animated: true)
        }else{
            let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "WarningInfoViewController") as! WarningInfoViewController
            self.navigationController?.pushViewController(mtrekmenu, animated: true)
        }
        
        
      
    }
    
    private func shouldHideUpdateButton(_ defaults: UserDefaults) -> Bool {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let kLatestVersion: String = "LATEST_VERSION_SUPPORTED"
            
            if let latestVersion = defaults.string(forKey: kLatestVersion),
                latestVersion.compare(appVersion, options: .numeric) == .orderedDescending {
                BFLog("Displaying update button. Current Version = (\(appVersion)) -- Server Version = (\(latestVersion))")
                
                // Update available
                return false
            }
        }
        
        return true
    }
    
    /**
     * Checks if we need to clear the meeting check in or out. This occurs if the day of the month
     * is >= 1 the day of the meeting check in, if == 1 will check if time is greater than 2 am. The
     * reason for 2 am is because some users may be in meetings past midnight.
     */
    private func attemptMeetingCheckInOutClear() {
        let defaults = UserDefaults.standard
        if let meetingCheckInTime = defaults.string(forKey: "meetingCheckInTime") {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy h:mm a"
            
            if let checkInDateTime = formatter.date(from: meetingCheckInTime) {
                let currentDateTime = Date()
                
                // Components for today
                let todayDay = Calendar.current.component(.day, from: currentDateTime)
                let todayMonth = Calendar.current.component(.month, from: currentDateTime)
                let todayYear = Calendar.current.component(.year, from: currentDateTime)
                let todayHour = Calendar.current.component(.hour, from: currentDateTime)
                
                // Components for check in day
                let checkInDay = Calendar.current.component(.day, from: checkInDateTime)
                let checkInMonth = Calendar.current.component(.month, from: checkInDateTime)
                let checkInYear = Calendar.current.component(.year, from: checkInDateTime)
                
                let dayDifference = todayDay - checkInDay
                
                if todayMonth != checkInMonth || todayYear != checkInYear {
                    // If the month or year is different we should clear check in
                    defaults.removeObject(forKey: "meetingCheckInTime")
                    
                    BFLog("month or year is different clearing meeting check in time")
                }
                else if dayDifference == 1 && todayHour >= 2 {
                    // Check if we're on the day after 2 am
                    defaults.removeObject(forKey: "meetingCheckInTime")
                    
                    BFLog("next day 2 am cutoff clearing meeting check in time")
                }
                else if dayDifference > 1 && todayDay > checkInDay {
                    // Check if today is beyond check in day
                    defaults.removeObject(forKey: "meetingCheckInTime")
                    
                    BFLog("today beyond check in clearing meeting check in time")
                }
                else {
                    BFLog("NOT clearing meeting check in time")
                }
                
                defaults.synchronize()
            }
            else {
                BFLog("An error ocurred while converting meeting check in time default to a string")
            }
        }
    }
    
    private func successfulLogin() {
        globalPlatform.globalPartId = partField.text!
        globalPlatform.globalPin = pinField.text!
        globalPlatform.globalProgramId = programField.text!
        
        let defaults = UserDefaults.standard
        var shouldClearDefaults = false
        
        // Clear defaults if the user logs into a new account
        if let globalProgramId = defaults.string(forKey: "globalProgramId"),
            let globalPartId = defaults.string(forKey: "globalPartId") {
            
            if globalPlatform.globalProgramId != globalProgramId
                || globalPlatform.globalPartId != globalPartId {
                shouldClearDefaults = true
            }
        }
        
        if shouldClearDefaults {
            defaults.removeObject(forKey: "globalPartId")
            defaults.removeObject(forKey: "globalPin")
            defaults.removeObject(forKey: "globalProgramId")
            defaults.removeObject(forKey: "dailyStatusCheckTime")
            defaults.removeObject(forKey: "facilityCheckInTime")
            defaults.removeObject(forKey: "facilityCheckOutTime")
            defaults.removeObject(forKey: "meetingCheckInTime")
            defaults.removeObject(forKey: "meetingCheckOutTime")
            defaults.removeObject(forKey: "pdfJson")
            defaults.removeObject(forKey: "loginSession")
            defaults.removeObject(forKey: "bacTrackDeviceUUID")
            defaults.removeObject(forKey: "SavedMeetingType")
            defaults.removeObject(forKey: "hasCompletedPreBac")
            defaults.removeObject(forKey: "testConfirmationNum")
            defaults.removeObject(forKey: "testStatusDate")
            defaults.removeObject(forKey: "testConfirmationMsg")
            defaults.removeObject(forKey: "testStatus")
            defaults.removeObject(forKey: "PDFJson")
            defaults.removeObject(forKey: "STORED_MEETING_NAME")
        }
        
        defaults.set(globalPlatform.baseUrl, forKey: "globalBaseURL")
        defaults.set(globalPlatform.globalPartId, forKey: "globalPartId")
        defaults.set(globalPlatform.globalPin, forKey: "globalPin")
        defaults.set(globalPlatform.globalProgramId, forKey: "globalProgramId")
        defaults.set(shouldRememberLogin, forKey: "shouldRememberLogin")
        
        defaults.synchronize()
    }
    
    private func commitOfflineBacTest() {
        let results = BACTestResult.query().fetch() as! [BACTestResult]
        
        if results.count > 0 {
            BFLog("\(results.count) BAC tests pending upload")
            
            results.forEach { bacTest in
                print(bacTest)
                bacTest.upload(completed: nil)
            }
        }
        else {
            BFLog("No BAC tests pending upload")
        }
    }
    
    private func showStandardAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var isCornerRadius: Bool {
        get {
            return layer.cornerRadius == 0
        }
        set {
            layer.cornerRadius = self.frame.size.height/2
            layer.masksToBounds = self.frame.size.height/2 > 0
        }
    }
    @IBInspectable var viewBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var viewBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    
}
