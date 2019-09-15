//
//  TestStatusDashboardViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/12/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD

class TestStatusDashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var colorPanelView: UIView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var testStatusTextView: UITextView!
    @IBOutlet weak var testStatusTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var helpLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewDocumentsButton: UIButton!
    @IBOutlet weak var viewDocumentsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollHintView: UIView!
    @IBOutlet weak var viewDocumentsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var helpLabelTopConstraint: NSLayoutConstraint!
    
    private let currentUser = Platform.shared()
    private var locationManager: CLLocationManager = CLLocationManager()
    private var didCaptureLocation: Bool = false
    private var progressHud: MBProgressHUD? = nil
    private var didLoad: Bool = false
    private var sobrietyDate: String? = nil
    private var notSelectedGreenColor = UIColor(red: 0.784, green: 0.902, blue: 0.788, alpha: 0.5)
    private var selectedRedColor = UIColor(red: 1, green: 0.804, blue: 0.824, alpha: 0.5)
    private var isScrollHintViewAnim = false
    fileprivate var titleId: [Int] = [Int]()
    fileprivate var facilityButtonTitles: [[String]] = [[String]]()
    fileprivate var questButtonTitles: [[String]] = [[String]]()
    private var barCodeImage: String? = nil
    private var questPdfString: String? = nil
    private var displayQuest: Bool = true
    var facilityArr = [String]()
    // MARK: - Overridden Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        sobrietyDate = currentUser.sobrietyDate
        
        testStatusTextView.delegate = self
        var questArr = [String]()
        questArr.append("Barcode")
        questArr.append("Authorization Form")
        // Add facility buttons
        
        if (currentUser.collectionSiteCheckIn){
            //            if currentUser.collectionSiteCheckInLocation
            //                || currentUser.collectionSiteCheckInSelfie {
            facilityArr.append("Check-In")
            //            }
        }
        if (currentUser.collectionSiteCheckOut){
            //            if currentUser.collectionSiteCheckOutLocation
            //                || currentUser.collectionSiteCheckOutSelfie {
            facilityArr.append("Check-Out")
            //            }
        }
        
        if facilityArr.count > 0 {
            titleId.append(0)
            facilityButtonTitles.append(facilityArr)
        }
        if(currentUser.questAuthorization){
            questButtonTitles.append(questArr)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = UserDefaults.standard
        if let barCodeImageString = defaults.string(forKey: "BarCode") {
            barCodeImage = barCodeImageString
        }
        if let questPdfStringText = defaults.string(forKey: "questPDF") {
            questPdfString = questPdfStringText
        }
        
        checkTimeWithDefaults(defaults)
        
        
        loadStatusFromDefaults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set back button text for the next screens to blank
        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.topItem?.title = "Test Status"
        
        // Right bar button
        let refreshButton = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(checkInButton_Clicked(_:)))
        self.tabBarController?.navigationItem.rightBarButtonItem = refreshButton;
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.navigationItem.rightBarButtonItem = nil;
    }
    
    // MARK: - IBAction Handlers
    
    @IBAction func checkInButton_Clicked(_ sender: UIButton) {
        progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHud?.label.text = "Loading..."
        
        didCaptureLocation = false
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func viewDocumentsButton_Clicked(_ sender: UIButton) {
        let pdfViewController = self.storyboard?.instantiateViewController(withIdentifier: "PDFWebViewController")
        self.navigationController?.pushViewController(pdfViewController!, animated: true)
    }
    // MARK: - UITableView Delegate
    // var isFacilityHistory : Bool = false
    
    var isFacility = false
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = self.tableView(tableView, titleForHeaderInSection: section)
        
        
        //self.tableView(tableView, titleForHeaderInSection: sectio/]
            if section == 0{
            //            print(sectionTitle)
            if currentUser.globalSobrietyDate && sobrietyDate != nil {
                return 1
            }
            else if currentUser.questAuthorization  {
                if(displayQuest){
                    return 2
                }
                else{
                    return 0
                }
            }
            else if (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckIn){
                isFacility = true
                return 2
            }
                /*else if currentUser.globalCheckInHistory {
                 return currentUser.checkInStatusHistory!.count
                 }
                 else if !(currentUser.globalCheckInHistory){
                 return 1
                 }*/
                
            else if currentUser.globalFacilityCheckInHistory{
                if currentUser.checkOutStatusHistory!.count != 0{
                    return currentUser.checkOutStatusHistory!.count
                }
                else{
                    return 1
                }
                
            }
            else if currentUser.globalCheckInHistory {
                if currentUser.checkInStatusHistory!.count != 0{
                    return currentUser.checkInStatusHistory!.count
                }
                else{
                    return 1
                }
                
            }
                //            else if !(currentUser.globalFacilityCheckInHistory){
                //                isFacilityHistory = true
                //                return 1
                //            }
            else{
                return 0
            }
        }else if section == 1{
            print(sectionTitle)
            if currentUser.globalSobrietyDate && sobrietyDate != nil{
                if currentUser.questAuthorization {
                    if(displayQuest){
                        return 2
                    }else{
                        return 0
                    }
                }
                else if(currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckIn)  {
                    return facilityArr.count
                }
                else if currentUser.globalCheckInHistory{
                    // return currentUser.checkInStatusHistory!.count
                    if currentUser.checkInStatusHistory!.count != 0{
                        return currentUser.checkInStatusHistory!.count
                    }
                    else{
                        return 1
                    }
                }
                    //                else if !(currentUser.globalCheckInHistory) && isFacilityHistory == true{
                    //                    return 1
                    //                }
                else if currentUser.globalFacilityCheckInHistory{
                    
                    //return currentUser.checkOutStatusHistory!.count
                    if currentUser.checkOutStatusHistory!.count != 0{
                        return currentUser.checkOutStatusHistory!.count
                    }
                    else{
                        return 1
                    }
                }
                    //                else if !(currentUser.globalFacilityCheckInHistory){
                    //                    isFacilityHistory = true
                    //                    return 1
                    //                }
                else{
                    return 0
                }
            }else{
                if (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckIn) && isFacility == false {
                    return facilityArr.count
                }
                else if currentUser.globalCheckInHistory {
                    if currentUser.checkInStatusHistory!.count != 0{
                        return currentUser.checkInStatusHistory!.count
                    }
                    else{
                        return 1
                    }
                    // return currentUser.checkInStatusHistory!.count
                }
                    //                else if !(currentUser.globalCheckInHistory) && isFacilityHistory == true{
                    //                    return 1
                    //                }
                else if currentUser.globalFacilityCheckInHistory{
                    if currentUser.checkOutStatusHistory!.count != 0{
                        return currentUser.checkOutStatusHistory!.count
                    }
                    else{
                        return 1
                    }
                    // return currentUser.checkOutStatusHistory!.count
                }
                    //                else if !(currentUser.globalFacilityCheckInHistory){
                    //                    isFacilityHistory = true
                    //                    return 1
                    //                }
                else{
                    return 0
                }
            }
        }else if section == 2{
            print(sectionTitle)
            
            if currentUser.globalSobrietyDate && sobrietyDate != nil{
                if currentUser.questAuthorization{
                    if (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckIn) {
                        return facilityArr.count
                    }
                    else if currentUser.globalCheckInHistory{
                        if currentUser.checkInStatusHistory!.count != 0{
                            return currentUser.checkInStatusHistory!.count
                        }
                        else{
                            return 1
                        }
                        //return currentUser.checkInStatusHistory!.count
                    }
                        //                    else if !(currentUser.globalCheckInHistory) && isFacilityHistory == true{
                        //                        return 1
                        //                    }
                    else if currentUser.globalFacilityCheckInHistory{
                        if currentUser.checkOutStatusHistory!.count != 0{
                            return currentUser.checkOutStatusHistory!.count
                        }
                        else{
                            return 1
                        }
                        //return currentUser.checkOutStatusHistory!.count
                    }
                        //                    else if !(currentUser.globalFacilityCheckInHistory){
                        //                        isFacilityHistory = true
                        //                        return 1
                        //                    }
                    else{
                        return 0
                    }
                }else{
                    /*if sectionTitle == "Collection Site Check-In/Out History"{
                     if currentUser.globalFacilityCheckInHistory{
                     return currentUser.checkOutStatusHistory!.count
                     }
                     else if !(currentUser.globalFacilityCheckInHistory){
                     return 1
                     }
                     }
                     else if sectionTitle == "Check In History"{
                     if currentUser.globalCheckInHistory {
                     return currentUser.checkInStatusHistory!.count
                     }
                     else if !(currentUser.globalCheckInHistory){
                     return 1
                     }
                     }
                     else{
                     return 0
                     }*/
                    if currentUser.globalCheckInHistory {
                        if currentUser.checkInStatusHistory!.count != 0{
                            return currentUser.checkInStatusHistory!.count
                        }
                        else{
                            return 1
                        }
                        //return currentUser.checkInStatusHistory!.count
                    }
                    //                    else if !(currentUser.globalCheckInHistory) && isFacilityHistory == true{
                    //                        return 1
                    //                    }
                    if currentUser.globalFacilityCheckInHistory{
                        if currentUser.checkOutStatusHistory!.count != 0{
                            return currentUser.checkOutStatusHistory!.count
                        }
                        else{
                            return 1
                        }
                        //return currentUser.checkOutStatusHistory!.count
                    }
                        //                    else if !(currentUser.globalFacilityCheckInHistory){
                        //                        isFacilityHistory = true
                        //                        return 1
                        //                    }
                        
                    else{
                        return 0
                    }
                }
            }else{
                if currentUser.questAuthorization{
                    
                    if currentUser.globalCheckInHistory {
                        if currentUser.checkInStatusHistory!.count != 0{
                            return currentUser.checkInStatusHistory!.count
                        }
                        else{
                            return 1
                        }
                        //return currentUser.checkInStatusHistory!.count
                    }
                        //                    else if !(currentUser.globalCheckInHistory) && isFacilityHistory == true{
                        //                        return 1
                        //                    }
                    else if currentUser.globalFacilityCheckInHistory{
                        if currentUser.checkOutStatusHistory!.count != 0{
                            return currentUser.checkOutStatusHistory!.count
                        }
                        else{
                            return 1
                        }
                        //return currentUser.checkOutStatusHistory!.count
                    }
                        //                    else if !(currentUser.globalFacilityCheckInHistory){
                        //                        isFacilityHistory = true
                        //                        return 1
                        //                    }
                        
                    else{
                        
                        return 0
                    }
                }else{
                    if currentUser.globalFacilityCheckInHistory{
                        if currentUser.checkOutStatusHistory!.count != 0{
                            return currentUser.checkOutStatusHistory!.count
                        }
                        else{
                            return 1
                        }
                        //return currentUser.checkOutStatusHistory!.count
                    }
                    //                    else{
                    //                        isFacilityHistory = true
                    //                        return 1
                    //                    }
                    return 0
                }
            }
        }else if section == 3{
            //            print(sectionTitle)
            if ((currentUser.globalSobrietyDate && sobrietyDate != nil) && currentUser.questAuthorization && (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckIn) && currentUser.globalCheckInHistory ){
                return currentUser.checkInStatusHistory!.count
            }
            else if currentUser.globalFacilityCheckInHistory {//&& isFacilityHistory == false{
                if currentUser.checkOutStatusHistory!.count != 0{
                    return currentUser.checkOutStatusHistory!.count
                }
                else{
                    return 1
                }
                //return currentUser.checkOutStatusHistory!.count
            }
                /*else if currentUser.globalCheckInHistory {
                 return currentUser.checkInStatusHistory!.count
                 }*/
                //            else if !(currentUser.globalCheckInHistory){
                //                return 1
                //            }
                
                //            else if currentUser.globalFacilityCheckInHistory{
                //                if (currentUser.checkOutStatusHistory!.count == 0){
                //                    return 1
                //                }
                //                else{
                //                    return currentUser.checkOutStatusHistory!.count
                //                }
                //            }
            else{
                return 0
            }
        }
        else {
            return 0
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sectionsCount = 0
        if (currentUser.questAuthorization){
            sectionsCount += 1
            print("Has quest authorization")
        }
        if (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckIn){
            sectionsCount += 1
            print("Has collection site checkin")
        }
        if (currentUser.globalFacilityCheckInHistory){
            sectionsCount += 1
        }
        if currentUser.globalSobrietyDate && sobrietyDate != nil {
            sectionsCount += 1
            print("Has global sobriety date")
        }
        if currentUser.globalCheckInHistory {
            sectionsCount += 1
            print("Has global checkin history")
        }
        //        sectionsCount += 2
        print(String(sectionsCount) + " Sections")
        return sectionsCount
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckIn) || currentUser.questAuthorization{
            if currentUser.questAuthorization{
                if section == 0{
                    if(displayQuest){
                        return "Lab Authorization"
                    }else{
                        return ""
                    }
                }
                else if currentUser.globalSobrietyDate && sobrietyDate != nil {
                    if section == 1 {
                        return "Sobriety Date"
                    }
                    else if section == 2{
                        if (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckIn){
                            return "Collection Site Check-In"
                        }else{
                            if (currentUser.globalCheckInHistory){
                                return "Check In History"
                            }
                            else if (currentUser.globalFacilityCheckInHistory){
                                return "Collection Site Check-In/Out History"
                            }
                            else{
                                return ""
                            }
                        }
                    }
                    else if section == 3{
                        if currentUser.globalCheckInHistory{
                            return "Check In History"
                        }else{
                            return ""
                        }
                    }else if section == 4{
                        return "Collection Site Check-In/Out History"
                    }
                    else{
                        return ""
                    }
                }
                else{
                    if section == 1{
                        if (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckIn){
                            return "Collection Site Check-In"
                        }else{
                            if currentUser.globalCheckInHistory{
                                return "Check In History"
                            }else{
                                return ""
                            }
                        }
                    }else if section == 2{
                        if currentUser.globalCheckInHistory && (currentUser.collectionSiteCheckIn  || currentUser.collectionSiteCheckOut){
                            return "Check In History"
                        }
                        else if (currentUser.globalFacilityCheckInHistory){
                            return "Collection Site Check-In/Out History"
                        }
                        else {
                            return ""
                        }
                    }
                    else if section == 3{
                        return "Collection Site Check-In/Out History"
                    }
                    else{
                        return ""
                    }
                }
            }else{
                if currentUser.globalSobrietyDate && sobrietyDate != nil {
                    if section == 0 {
                        return "Sobriety Date"
                    }
                    else if section == 1 {
                        return "Collection Site Check-In"
                    }else if section == 2{
                        if (currentUser.globalCheckInHistory){
                            return "Check In History"
                        }
                        else if (currentUser.globalFacilityCheckInHistory){
                            return "Collection Site Check-In/Out History"
                        }
                            
                        else{
                            return ""
                        }
                    }
                    else if section == 3{
                        return "Collection Site Check-In/Out History"
                    }
                    else{
                        return ""
                    }
                }else{
                    if section == 0{
                        return "Collection Site Check-In"
                    }else if section == 1{
                        if (currentUser.globalCheckInHistory){
                            return "Check In History"
                        }
                        else{
                            return ""
                        }
                    }
                    else if section == 2{
                        return "Collection Site Check-In/Out History"
                    }
                    else{
                        return ""
                    }
                }
            }
        }
        else if currentUser.globalSobrietyDate && sobrietyDate != nil {
            if section == 0 {
                return "Sobriety Date"
            }
            else if section == 1 {
                return "Check In History"
            }
            else if section == 2{
                return "Collection Site Check-In/Out History"
            }
            else {
                return ""
            }
        }
        else if currentUser.globalCheckInHistory {
            if section == 0 {
                return "Check In History"
            }
            else if section == 1{
                return "Collection Site Check-In/Out History"
            }
            else {
                return ""
            }
        }
        else {
            return nil
            /*if section == 0 {
             return "Check In History"
             }
             else if section == 1{
             return "Collection Site Check-In/Out History"
             }
             else {
             return ""
             }*/
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionTitle = self.tableView(tableView, titleForHeaderInSection: indexPath.section)
        //        print("Title " + sectionTitle! + "Section : " + String(indexPath.section) + "Row : " + String(indexPath.row) )
        if(sectionTitle == "Sobriety Date"){
            let cell = UITableViewCell()
            if let sdate = sobrietyDate {
                cell.textLabel?.text = sdate
            }
            else {
                cell.textLabel?.text = "Error finding Sobriety Date"
            }
            return cell
        }else if (sectionTitle == "Lab Authorization"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
            cell.titleLabel.text = questButtonTitles[0][indexPath.row]
            print("Quest Authorization " + String(indexPath.row) + " " + questButtonTitles[0][indexPath.row])
            return cell
        }else if (sectionTitle == "Collection Site Check-In") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
            cell.titleLabel.text = facilityButtonTitles[0][indexPath.row]
            //            print("Collection Site Check-In " + String(indexPath.row) + " " + facilityButtonTitles[0][indexPath.row])
            return cell
        }else if(sectionTitle == "Check In History"){
            if (currentUser.checkInStatusHistory?.count != 0) && currentUser.globalCheckInHistory{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
                cell.titleLabel.text = currentUser.checkInStatusHistory![indexPath.row].splitDate
                //                print("Check In History " + String(indexPath.row) + " " + currentUser.checkInStatusHistory![indexPath.row].date)
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoResultCell", for: indexPath) as! ButtonTableViewCell
                cell.noResultLabel.text = "No Result"//currentUser.checkInStatusHistory![indexPath.row].date
                //print("Check In History " + String(indexPath.row) + " " + currentUser.checkInStatusHistory![indexPath.row].date)
                return cell
            }
            /*let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
             cell.titleLabel.text = currentUser.checkInStatusHistory![indexPath.row].splitDate
             return cell*/
            
        }
        else if(sectionTitle == "Collection Site Check-In/Out History"){
            if (currentUser.checkOutStatusHistory?.count != 0) && currentUser.globalFacilityCheckInHistory{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
                cell.titleLabel.text = currentUser.checkOutStatusHistory![indexPath.row].checkInDate ?? " " + " - " + currentUser.checkOutStatusHistory![indexPath.row].checkOutDate!
                
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoResultCell", for: indexPath) as! ButtonTableViewCell
                cell.noResultLabel.text = "No Result"
                return cell
            }
            /* let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
             cell.titleLabel.text = currentUser.checkOutStatusHistory![indexPath.row].checkInDate ?? " " + " - " + currentUser.checkOutStatusHistory![indexPath.row].checkOutDate!
             
             return cell*/
            
        }
        else {
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionTitle = self.tableView(tableView, titleForHeaderInSection: indexPath.section)
        //        print("Selected Section Title: " + sectionTitle! + " Section : " + String(indexPath.section) + "Row : " + String(indexPath.row) )
        if(sectionTitle == "Sobriety Date"){
            // True if the user has sobriety date permission and a valid sobriety date
            
            let isSobrietyEnabled = (currentUser.globalSobrietyDate && sobrietyDate != nil)
            
            guard !isSobrietyEnabled || (isSobrietyEnabled && indexPath.section != 0) else {
                return
            }
        }else if (sectionTitle == "Lab Authorization"){
            print(questButtonTitles[0][indexPath.row] + " Clicked")
            if(indexPath.row == 0){
                
                if barCodeImage != nil{
                    let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 256, height: 150)))
                    imageView.image = UIImage(data: Data(base64Encoded: barCodeImage!)!)
                    
                    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.isOpaque, 0.0)
                    defer { UIGraphicsEndImageContext() }
                    let context = UIGraphicsGetCurrentContext()
                    imageView.layer.render(in: context!)
                    let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                    
                    let alertMessage = UIAlertController(title: "Lab Authorization", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "", style: .default, handler: nil)
                    action.setValue(finalImage?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), forKey: "image")
                    alertMessage .addAction(action)
                    let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertMessage .addAction(action1)
                    
                    self.present(alertMessage, animated: true, completion: nil)
                }else{
                    let alertMessage = UIAlertController(title: "Mobile Trek", message: "No barcode found", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertMessage .addAction(action1)
                    self.present(alertMessage, animated: true, completion: nil)
                }
            }else if(indexPath.row == 1){
                if #available(iOS 11.0, *) {
                    
                    if (questPdfString != nil){
                        let pdfViewController = self.storyboard?.instantiateViewController(withIdentifier: "QuestPDFWebView") as! QuestPDFWebViewController
                        pdfViewController.encodedPDFData = questPdfString
                        print(questPdfString!)
                        self.navigationController?.pushViewController(pdfViewController, animated: true)
                    }else{
                        let alertMessage = UIAlertController(title: "Mobile Trek", message: "No Authorization form found", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertMessage .addAction(action1)
                        self.present(alertMessage, animated: true, completion: nil)
                    }
                } else {
                    // Fallback on earlier versions
                }
                
            }
        }else if (sectionTitle == "Collection Site Check-In"){
            print(facilityButtonTitles[0][indexPath.row] + " Clicked")
            let currentButtonTitle = facilityButtonTitles[0][indexPath.row]
            
            if currentButtonTitle == "Check-In" { gotoCheckIn() }
            if currentButtonTitle == "Check-Out" { gotoCheckOut() }
        }else if(sectionTitle == "Check In History"){
            if let checkInHistory = currentUser.checkInStatusHistory {
                let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "historyVC") as! HistoryViewController
                historyVC.vcTitle = "Test Status History"
                
                // Create data for history VC, this will be the info we show when
                // the history item is selected
                var data: [String] = [String]()
                
                if checkInHistory.count == 0 {
                    return
                }
                // Check if we can display date and status separately
                if let splitDate = checkInHistory[indexPath.row].splitDate,
                    let status = checkInHistory[indexPath.row].status {
                    data.append("Date: \(splitDate)")
                    data.append("Status: \(status)")
                }
                else {
                    data.append("Date: \(currentUser.checkInStatusHistory![indexPath.row].date)")
                }
                
                // Show confirmation num if available
                let confirmationNum = checkInHistory[indexPath.row].confirmationNum
                if !confirmationNum.isEmpty {
                    data.append("Confirmation #: \(confirmationNum)")
                }
                
                // Show if they were selected for testing by displaying Yes or No
                data.append("Selected: \((checkInHistory[indexPath.row].selectedForTesting) ? "Yes" : "No")")
                
                historyVC.data = data
                
                self.navigationController?.pushViewController(historyVC, animated: true)
            }
            else {
                BFLog("User attempted to click on check in history item, but checkin status history is nil", tag: "CheckInHistory Nil Item Click", level: .error)
            }
        }
        else if(sectionTitle == "Collection Site Check-In/Out History"){
            gotoHistory(index: indexPath.row)
        }
        else {
            
        }
        
        
        
    }
    func gotoHistory(index: Int){
        var tempData = [String]()
        
        if (currentUser.checkOutStatusHistory?.count == 0 ){
            return
        }
        if let checkinDate = currentUser.checkOutStatusHistory![index].checkInDate {
            tempData.append("Check-In: \(checkinDate)")
        }
        
        if let checkOutDate = currentUser.checkOutStatusHistory![index].checkOutDate {
            tempData.append("Check-Out: \(checkOutDate)")
        }
        let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "historyVC") as! HistoryViewController
        historyVC.vcTitle = "Test Status History"
        historyVC.data = tempData
        self.navigationController?.pushViewController(historyVC, animated: true)
    }
    fileprivate func gotoCheckIn() {
        //        currentUser.cocOptionNumber = true
        //        currentUser.cocNumber = true
        //        currentUser.cocLogData = true
        //        currentUser.cocObserved = true
        currentUser.checkinorout = "checkin"
        currentUser.checkInType = "facilitycheckincheckout"
        if !(currentUser.cocLogData){
            branchGotoNextVCCheckInFacility()
            return
        }
        if(self.currentUser.cocNumber || self.currentUser.cocOptionNumber){
            self.showCOCAlert()
        }else if(self.currentUser.cocObserved){
            self.showCOCObservedAlert()
        }else{
            branchGotoNextVCCheckInFacility()
        }
    }
    
    fileprivate func gotoCheckOut() {
        currentUser.checkinorout = "checkout"
        currentUser.checkInType = "facilitycheckincheckout"
        if !(currentUser.cocLogData){
            branchGotoNextVCCheckInFacility()
            return
        }
        if(self.currentUser.cocNumberCheckOut || self.currentUser.cocOptionNumberCheckOut){
            self.showCOCAlertCheckout()
        }else if(self.currentUser.cocObservedCheckOut){
            self.showCOCObservedAlertCheckout()
        }else{
            branchGotoNextVCCheckOutFacility()
        }
    }
    /**
     * Decides what VC comes next depending on constraints for FacilityCheckIn
     */
    fileprivate func branchGotoNextVCCheckInFacility() {
        if self.currentUser.collectionSiteCheckInLocation {
            let checkInOut = self.storyboard?.instantiateViewController(withIdentifier: "checkInOut") as! CheckInLocationViewController
            checkInOut.isSelfieRequired = self.currentUser.collectionSiteCheckInSelfie
            checkInOut.isFormRequired = self.currentUser.cocFormCheckIn
            self.navigationController?.pushViewController(checkInOut, animated: true)
        }
        else if self.currentUser.collectionSiteCheckInSelfie {
            let checkInSelfie = self.storyboard?.instantiateViewController(withIdentifier: "checkInSelfie") as! CheckInSelfieViewController
            checkInSelfie.isFormPictureRequired = self.currentUser.cocFormCheckIn
            self.navigationController?.pushViewController(checkInSelfie, animated: true)
        }
        else if self.currentUser.cocFormCheckIn{
            let cocFormCheckInPicture = self.storyboard?.instantiateViewController(withIdentifier: "formCheckInView") as! FormPictureController
            self.navigationController?.pushViewController(cocFormCheckInPicture, animated: true)
        }
        else {
            progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHud?.label.text = "Uploading"
            
            // Location and selfie aren't required send the request
            sendBlankRequest(true, isMeeting: false)
        }
    }
    
    /**
     * Decides what VC comes next depending on constraints for FacilityCheckOut
     */
    fileprivate func branchGotoNextVCCheckOutFacility() {
        if self.currentUser.collectionSiteCheckOutLocation {
            let checkOut = self.storyboard?.instantiateViewController(withIdentifier: "checkOut") as! CheckOut
            checkOut.isSelfieRequired = self.currentUser.collectionSiteCheckOutSelfie
            checkOut.isFormPictureRequired = self.currentUser.cocFormCheckOut
            self.navigationController?.pushViewController(checkOut, animated: true)
        }
        else if self.currentUser.collectionSiteCheckOutSelfie {
            let checkOutSelfie = self.storyboard?.instantiateViewController(withIdentifier: "checkOutSelfie") as! CheckOutSelfieViewController
            checkOutSelfie.isFormPictureRequired = self.currentUser.cocFormCheckOut
            self.navigationController?.pushViewController(checkOutSelfie, animated: true)
        }else if self.currentUser.cocFormCheckOut{
            
            let cocFormCheckInPicture = self.storyboard?.instantiateViewController(withIdentifier: "formCheckInView") as! FormPictureController
            self.navigationController?.pushViewController(cocFormCheckInPicture, animated: true)
            
            
        }
        else {
            progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHud?.label.text = "Uploading"
            
            // Location and selfie aren't required send the request
            sendBlankRequest(false, isMeeting: false)
        }
    }
    fileprivate func showCOCObservedAlert() {
        let alert = UIAlertController(title: "COC Log Data", message:"COC Observed?", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.currentUser.cocObservedText = true
            self.branchGotoNextVCCheckInFacility()
            return
            //}else if(self.currentUser.checkinorout == "checkout"){
            //    self.branchGotoNextVCCheckOutFacility()
            //    return
            //}
            //else{
            //    return
            //}
            
        })
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.currentUser.cocObservedText = false
            //if(self.currentUser.checkinorout == "checkin"){
            self.branchGotoNextVCCheckInFacility()
            return
            //}else if(self.currentUser.checkinorout == "checkout"){
            //   self.branchGotoNextVCCheckOutFacility()
            //    return
            //}
            //else{
            //    return
            //}
            
        })
        
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func showCOCObservedAlertCheckout() {
        let alert = UIAlertController(title: "COC Log Data", message:"COC Observed?", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.currentUser.cocObservedCheckoutText = true
            self.branchGotoNextVCCheckOutFacility()
            return
            //}else if(self.currentUser.checkinorout == "checkout"){
            //    self.branchGotoNextVCCheckOutFacility()
            //    return
            //}
            //else{
            //    return
            //}
            
        })
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.currentUser.cocObservedCheckoutText = false
            //if(self.currentUser.checkinorout == "checkin"){
            self.branchGotoNextVCCheckOutFacility()
            return
            //}else if(self.currentUser.checkinorout == "checkout"){
            //   self.branchGotoNextVCCheckOutFacility()
            //    return
            //}
            //else{
            //    return
            //}
            
        })
        
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func validate(textfield: UITextField, action: UIAlertAction) {
        
    }
    
    fileprivate func showCOCAlert() {
        let alert = UIAlertController(title: "COC Log Data", message:"", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
            if let textFields = alert.textFields{
                if(self.currentUser.cocNumber){
                    let cocNumber = textFields[0].text
                    let cocNumberText = cocNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.currentUser.cocNumberText = cocNumberText ?? ""
                }
                if(self.currentUser.cocOptionNumber){
                    var index: Int = 0;
                    if(self.currentUser.cocNumber){
                        index += 1;
                    }
                    let cocOptionNumber = textFields[index].text
                    let cocOptionNumberText = cocOptionNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.currentUser.cocOptionNumberText = cocOptionNumberText ?? ""
                }
                if(self.currentUser.cocObserved){
                    self.showCOCObservedAlert()
                }else{
                    if(self.currentUser.checkinorout == "checkin"){
                        self.branchGotoNextVCCheckInFacility()
                        return
                    }else if(self.currentUser.checkinorout == "checkout"){
                        self.branchGotoNextVCCheckOutFacility()
                        return
                    }
                    else{
                        return
                    }
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        doneAction.isEnabled = false
        
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        var isCOCNumber = false
        var isCOCOptionNumber = false
        if(self.currentUser.cocNumber){
            alert.addTextField{ (cocNumber) in
                cocNumber.placeholder = "COC Number"
                
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: cocNumber, queue: OperationQueue.main, using:
                    {_ in
                        if self.currentUser.cocNumber && self.currentUser.cocOptionNumber{
                            if !(cocNumber.text!.isEmpty){
                                isCOCNumber = true
                                doneAction.isEnabled = !cocNumber.text!.isEmpty && isCOCOptionNumber
                            }
                                
                            else{
                                doneAction.isEnabled = false
                                isCOCNumber = false
                                //doneAction.isEnabled = !cocNumber.text!.isEmpty && isCOCOptionNumber
                            }
                        }
                        else if self.currentUser.cocNumber{
                            doneAction.isEnabled = !cocNumber.text!.isEmpty
                        }
                        
                        
                })
                
            }
        }
        if(self.currentUser.cocOptionNumber){
            alert.addTextField{ (cocOptNumber) in
                cocOptNumber.placeholder = "COC Option Number"
                
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: cocOptNumber, queue: OperationQueue.main, using:
                    {_ in
                        if self.currentUser.cocNumber && self.currentUser.cocOptionNumber{
                            if !(cocOptNumber.text!.isEmpty){
                                doneAction.isEnabled = !cocOptNumber.text!.isEmpty && isCOCNumber
                                isCOCOptionNumber = true
                            }
                            else{
                                isCOCOptionNumber = false
                                doneAction.isEnabled = false
                            }
                        }
                        else if self.currentUser.cocOptionNumber{
                            doneAction.isEnabled = !cocOptNumber.text!.isEmpty
                        }
                        
                        
                })
            }
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    fileprivate func showCOCAlertCheckout() {
        let alert = UIAlertController(title: "COC Log Data", message:"", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
            if let textFields = alert.textFields{
                if(self.currentUser.cocNumberCheckOut){
                    let cocNumber = textFields[0].text
                    let cocNumberText = cocNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.currentUser.cocNumberCheckoutText = cocNumberText ?? ""
                }
                if(self.currentUser.cocOptionNumberCheckOut){
                    var index: Int = 0;
                    if(self.currentUser.cocNumberCheckOut){
                        index += 1;
                    }
                    let cocOptionNumber = textFields[index].text
                    let cocOptionNumberText = cocOptionNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.currentUser.cocOptionNumberCheckoutText = cocOptionNumberText ?? ""
                }
                if(self.currentUser.cocObservedCheckOut){
                    self.showCOCObservedAlertCheckout()
                }else{
                    if(self.currentUser.checkinorout == "checkin"){
                        self.branchGotoNextVCCheckInFacility()
                        return
                    }else if(self.currentUser.checkinorout == "checkout"){
                        self.branchGotoNextVCCheckOutFacility()
                        return
                    }
                    else{
                        return
                    }
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        doneAction.isEnabled = false
        
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        var isCOCNumber = false
        var isCOCOptionNumber = false
        if(self.currentUser.cocNumberCheckOut){
            alert.addTextField{ (cocNumber) in
                cocNumber.placeholder = "COC Number"
                
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: cocNumber, queue: OperationQueue.main, using:
                    {_ in
                        if self.currentUser.cocNumberCheckOut && self.currentUser.cocOptionNumberCheckOut{
                            if !(cocNumber.text!.isEmpty){
                                isCOCNumber = true
                                doneAction.isEnabled = !cocNumber.text!.isEmpty && isCOCOptionNumber
                            }
                                
                            else{
                                doneAction.isEnabled = false
                                isCOCNumber = false
                                //doneAction.isEnabled = !cocNumber.text!.isEmpty && isCOCOptionNumber
                            }
                        }
                        else if self.currentUser.cocNumberCheckOut{
                            doneAction.isEnabled = !cocNumber.text!.isEmpty
                        }
                        
                        
                })
                
            }
        }
        if(self.currentUser.cocOptionNumberCheckOut){
            alert.addTextField{ (cocOptNumber) in
                cocOptNumber.placeholder = "COC Option Number"
                
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: cocOptNumber, queue: OperationQueue.main, using:
                    {_ in
                        if self.currentUser.cocNumberCheckOut && self.currentUser.cocOptionNumberCheckOut{
                            if !(cocOptNumber.text!.isEmpty){
                                doneAction.isEnabled = !cocOptNumber.text!.isEmpty && isCOCNumber
                                isCOCOptionNumber = true
                            }
                            else{
                                isCOCOptionNumber = false
                                doneAction.isEnabled = false
                            }
                        }
                        else if self.currentUser.cocOptionNumberCheckOut{
                            doneAction.isEnabled = !cocOptNumber.text!.isEmpty
                        }
                        
                        
                })
            }
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - CLLocationManager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let firstLocation = locations.first {
            if !didCaptureLocation {
                manager.stopUpdatingLocation()
                
                let currentLocation = firstLocation
                let coord = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                
                sendRequest(String(coord.latitude), gpsLong: String(coord.longitude))
                
                didCaptureLocation = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        sendRequest("0", gpsLong: "0")
    }
    
    // MARK: - Private & Helper Functions
    
    fileprivate func sendRequest(_ gpsLat: String, gpsLong: String) {
        let statusRequest = NTDailyStatusRequest(baseUrl: currentUser.baseUrl, participantId: currentUser.globalPartId,
                                                 pin: currentUser.globalPin, gpsLat: gpsLat, gpsLong: gpsLong)
        statusRequest.sendRequest { message, confirmationNumber, confirmationMessage, programMessage, specialMessage, pdfJson, barCode, questPdf in
            self.progressHud?.hide(animated: true)
            
            let timeStamp = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy hh:mm a"
            self.barCodeImage = barCode
            self.questPdfString = questPdf
            let defaults = UserDefaults(suiteName: "group.rtrek.mobiletrek")
            defaults?.setValue(message, forKey: "dailyTestStatus")
            defaults?.setValue(formatter.string(from: timeStamp), forKey: "statusLastChecked")
            defaults?.synchronize()
            
            if let echainPdf = pdfJson {
                let uDefaults = UserDefaults.standard
                uDefaults.setValue(echainPdf, forKey: "PDFJson")
                uDefaults.synchronize()
            }
            else {
                // Remove PDF from defaults if it's there
                let uDefaults = UserDefaults.standard
                uDefaults.removeObject(forKey: "PDFJson")
            }
            
            if let barCodeString = barCode {
                let uDefaults = UserDefaults.standard
                uDefaults.setValue(barCodeString, forKey: "BarCode")
                uDefaults.synchronize()
            }
            else {
                // Remove PDF from defaults if it's there
                let uDefaults = UserDefaults.standard
                uDefaults.removeObject(forKey: "BarCode")
            }
            if let questPdfEncodedString = questPdf {
                let uDefaults = UserDefaults.standard
                uDefaults.setValue(questPdfEncodedString, forKey: "questPDF")
                uDefaults.synchronize()
            }
            else {
                // Remove PDF from defaults if it's there
                let uDefaults = UserDefaults.standard
                uDefaults.removeObject(forKey: "questPDF")
            }
            if self.buildAttributedTestMessage(true, testStatus: message, confirmNum: confirmationNumber, confirmMsg: confirmationMessage,
                                               programMsg: programMessage, specialMsg: specialMessage, isPDFAvailable: (pdfJson != nil)) {
                self.helpLabel.isHidden = true
                self.helpLabelHeightConstraint.constant = 0
                self.helpLabel.text = nil
                
                self.colorPanelView.isHidden = false
                
                self.checkInButton.isHidden = true
                self.testStatusTextView.isHidden = false
            }
        }
    }
    
    fileprivate func buildAttributedTestMessage(_ isForced: Bool, testStatus: String?, confirmNum: String?,
                                                confirmMsg: String?, programMsg: String?, specialMsg: String?,
                                                isPDFAvailable: Bool) -> Bool {
        let testStatusAttr = NSMutableAttributedString()
        let confirmAttr = NSMutableAttributedString()
        let headerFont = UIFont.boldSystemFont(ofSize: 16)
        let descFont = UIFont(name: "Helvetica-Light", size: 14)!
        let defaults = UserDefaults.standard
        
        if let newTestStatus = testStatus {
            testStatusAttr.append(NSAttributedString(string: "Test Selection Status: \n",
                                                     attributes: [NSAttributedString.Key.font:headerFont, NSAttributedString.Key.foregroundColor:UIColor.blue]))
            
            let notSelectedText = "NO / NOT SELECTED"
            let yesSelectedText = "YES / SELECTED"
            
            let greenColor = UIColor(red: 0.22, green: 0.557, blue: 0.235, alpha: 1.0)
            
            if newTestStatus.range(of: notSelectedText) != nil {
                // Color the text green
                let textLengthToColor = 17
                let removedText = String(newTestStatus.dropFirst(textLengthToColor))
                
                testStatusAttr.append(NSAttributedString(string: notSelectedText, attributes: [NSAttributedString.Key.font:descFont, NSAttributedString.Key.foregroundColor:greenColor]))
                testStatusAttr.append(NSAttributedString(string: removedText,
                                                         attributes: [NSAttributedString.Key.font:descFont, NSAttributedString.Key.foregroundColor:UIColor.black]))
                
                colorPanelView.backgroundColor = notSelectedGreenColor
                self.displayQuest = true
                self.historyTableView.reloadData()
                print("setting display quest to false")
                
            }
            else if newTestStatus.range(of: yesSelectedText) != nil {
                // Color the text red
                let textLengthToColor = 14
                let removedText = String(newTestStatus.dropFirst(textLengthToColor))
                
                testStatusAttr.append(NSAttributedString(string: yesSelectedText, attributes: [NSAttributedString.Key.font:descFont, NSAttributedString.Key.foregroundColor:UIColor.red]))
                testStatusAttr.append(NSAttributedString(string: removedText,
                                                         attributes: [NSAttributedString.Key.font:descFont, NSAttributedString.Key.foregroundColor:UIColor.black]))
                
                colorPanelView.backgroundColor = selectedRedColor
                self.displayQuest = true
                self.historyTableView.reloadData()
                print("setting display quest to true")
            }
            else {
                testStatusAttr.append(NSAttributedString(string: newTestStatus,
                                                         attributes: [NSAttributedString.Key.font:descFont]))
                
                colorPanelView.backgroundColor = UIColor.white
            }
            
            defaults.set(newTestStatus, forKey: "testStatus")
            
            // Add confirmation number and message
            if let newConfirmNum = confirmNum,
                let newConfirmMsg = confirmMsg {
                confirmAttr.append(NSAttributedString(string: "\n\n"))
                
                confirmAttr.append(NSAttributedString(string: "Confirmation #: ",
                                                      attributes: [NSAttributedString.Key.font:headerFont, NSAttributedString.Key.foregroundColor:UIColor.blue]))
                
                confirmAttr.append(NSAttributedString(string: newConfirmNum,
                                                      attributes: [NSAttributedString.Key.font:headerFont, NSAttributedString.Key.foregroundColor:UIColor.red]))
                
                confirmAttr.append(NSAttributedString(string: "\n"))
                
                confirmAttr.append(NSAttributedString(string: newConfirmMsg,
                                                      attributes: [NSAttributedString.Key.font:descFont]))
                
                testStatusAttr.append(confirmAttr)
                
                defaults.set(newConfirmNum, forKey: "testConfirmationNum")
                defaults.set(newConfirmMsg, forKey: "testConfirmationMsg")
            }
            else {
                defaults.removeObject(forKey: "testConfirmationNum")
                defaults.removeObject(forKey: "testConfirmationMsg")
            }
            
            // Add special message
            if let specialMessage = specialMsg {
                let attrStr = NSMutableAttributedString()
                attrStr.append(NSAttributedString(string: "\n\n"))
                
                attrStr.append(NSAttributedString(string: "Special message:",
                                                  attributes: [NSAttributedString.Key.font:headerFont, NSAttributedString.Key.foregroundColor:UIColor.blue]))
                
                attrStr.append(NSAttributedString(string: "\n"))
                
                attrStr.append(NSAttributedString(string: specialMessage,
                                                  attributes: [NSAttributedString.Key.font:descFont]))
                
                testStatusAttr.append(attrStr)
                
                defaults.set(specialMessage, forKey: "specialMsg")
            }
            else {
                defaults.removeObject(forKey: "specialMsg")
            }
            
            // Add program message
            if let programMessage = programMsg {
                let attrStr = NSMutableAttributedString()
                attrStr.append(NSAttributedString(string: "\n\n"))
                
                attrStr.append(NSAttributedString(string: "Program message:",
                                                  attributes: [NSAttributedString.Key.font:headerFont, NSAttributedString.Key.foregroundColor:UIColor.blue]))
                
                attrStr.append(NSAttributedString(string: "\n"))
                
                attrStr.append(NSAttributedString(string: programMessage,
                                                  attributes: [NSAttributedString.Key.font:descFont]))
                
                testStatusAttr.append(attrStr)
                
                defaults.set(programMessage, forKey: "programMsg")
            }
            else {
                defaults.removeObject(forKey: "programMsg")
            }
            
            testStatusTextView.attributedText = testStatusAttr
            
            if isPDFAvailable {
                viewDocumentsButton.isHidden = false
                viewDocumentsHeightConstraint.constant = 27
            }
            else {
                viewDocumentsButton.isHidden = true
                viewDocumentsHeightConstraint.constant = 0
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
            
            if isForced {
                defaults.set(formatter.string(from: Date()), forKey: "testStatusDate")
            }
            
            defaults.synchronize()
            
            print("chars = \(testStatusTextView.text.count)")
            if testStatusTextView.text.count >= 300 {
                self.view.removeConstraint(testStatusTextViewHeight)
                
                testStatusTextView.isScrollEnabled = true
                testStatusTextView.contentOffset = .zero
                
                self.view.addConstraint(NSLayoutConstraint(
                    item: testStatusTextView,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1.0,
                    constant: 180))
                
                Graphics.addRoundedCorners(view: scrollHintView, corners: .allCorners, radius: 20)
                scrollHintView.alpha = 0.8
                
                viewDocumentsBottomConstraint.constant = 0
                helpLabelTopConstraint.constant = 0
            }
            
            return true
        }
        else {
            let alert = UIAlertController(title: "Connection Error",
                                          message: "MobileTrek was unable to contact the server. Please try again in a few minutes.",
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    fileprivate func checkTimeWithDefaults(_ defaults: UserDefaults) {
        if validateCheckTimeWithDefaults(defaults, defaultKey: "dailyStatusCheckTime") {
            defaults.removeObject(forKey: "PDFJson")
        }
        
        _ = validateCheckTimeWithDefaults(defaults, defaultKey: "facilityCheckInTime")
        _ = validateCheckTimeWithDefaults(defaults, defaultKey: "facilityCheckOutTime")
        _ = validateCheckTimeWithDefaults(defaults, defaultKey: "meetingCheckInTime")
        _ = validateCheckTimeWithDefaults(defaults, defaultKey: "meetingCheckOutTime")
        
        if validateCheckTimeWithDefaults(defaults, defaultKey: "testStatusDate") {
            BFLog("Removed testing status defaults")
            
            defaults.removeObject(forKey: "testStatus")
            defaults.removeObject(forKey: "testConfirmationNum")
            defaults.removeObject(forKey: "testConfirmationMsg")
        }
        
        defaults.synchronize()
    }
    
    fileprivate func validateCheckTimeWithDefaults(_ defaults: UserDefaults, defaultKey: String) -> Bool {
        var wasRemoved = false
        
        if let defObj = defaults.string(forKey: defaultKey) {
            if pendingClearOfDate(defObj) {
                defaults.removeObject(forKey: defaultKey)
                wasRemoved = true
                
                BFLog("Cleared \(defObj)")
            }
            else {
                BFLog("Will not clear \(defObj)")
            }
        }
        
        return wasRemoved
    }
    
    fileprivate func pendingClearOfDate(_ date: String) -> Bool {
        let format24 = "MM/dd/yyyy HH:mm"
        let format12 = "MM/dd/yyyy hh:mm a"
        
        let dateFormat = DateFormatter()
        
        // try 12 hour time
        dateFormat.dateFormat = format12
        if dateFormat.date(from: date) == nil {
            
            // try 24 hour time
            dateFormat.dateFormat = format24
            if dateFormat.date(from: date) == nil {
                return true
            }
        }
        
        let cal = Calendar.current
        let timeCheckDate = dateFormat.date(from: date)
        let comp = (cal as NSCalendar).components([.month, .day, .year], from: timeCheckDate!)
        
        let todayDate = Date()
        let todayComp = (cal as NSCalendar).components([.month, .day, .year], from: todayDate)
        
        if comp.month != todayComp.month
            || comp.day != todayComp.day
            || comp.year != todayComp.year {
            return true
        }
        else {
            return false
        }
    }
    
    fileprivate func loadStatusFromDefaults() {
        let defaults = UserDefaults.standard
        
        if let testStatus = defaults.string(forKey: "testStatus") {
            BFLog("User has checked in with status: \(testStatus)")
            
            var isPDFAvailable = false
            
            if let _ = defaults.string(forKey: "PDFJson") {
                isPDFAvailable = true
            }
            
            _ = buildAttributedTestMessage(false, testStatus: testStatus,
                                           confirmNum: defaults.string(forKey: "testConfirmationNum"),
                                           confirmMsg: defaults.string(forKey: "testConfirmationMsg"),
                                           programMsg: defaults.string(forKey: "programMsg"),
                                           specialMsg: defaults.string(forKey: "specialMsg"),
                                           isPDFAvailable: isPDFAvailable)
            self.helpLabel.isHidden = true
            self.helpLabelHeightConstraint.constant = 0
            self.helpLabel.text = nil
            
            self.colorPanelView.isHidden = false
            
            self.checkInButton.isHidden = true
            self.testStatusTextView.isHidden = false
        }
        else {
            BFLog("User has not checked in today")
            
            self.helpLabel.text = "You have not checked in today!"
            self.helpLabel.isHidden = false
            self.helpLabelHeightConstraint.constant = 21
            
            self.colorPanelView.isHidden = false
            
            self.checkInButton.isHidden = false
            self.testStatusTextView.text = ""
            self.testStatusTextView.isHidden = true
        }
    }
    fileprivate func sendBlankRequest(_ isCheckIn: Bool, isMeeting: Bool) {
        let checkInOutRequest = NTCheckInOutRequest(baseUrl: self.currentUser.baseUrl, participantId: self.currentUser.globalPartId, pin: self.currentUser.globalPin,
                                                    checkInType: self.currentUser.checkInType, action: (isCheckIn) ? "checkin" : "checkout", gpsLat: "0.00",
                                                    gpsLong: "0.00", meetingType: self.currentUser.meetingType)
        
        checkInOutRequest.sendRequest { message in
            self.progressHud?.hide(animated: true)
            
            var alertTitle = (isCheckIn) ? "Check-In" : "Check-Out"
            
            if (message == "success" || !isMeeting) {
                if isMeeting && message == "success" {
                    let defaults = UserDefaults.standard
                    
                    if isCheckIn {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MM/dd/yyyy h:mm a"
                        if self.currentUser.checkInType == "facilitycheckincheckout" {
                            defaults.set(formatter.string(from: Date()), forKey: "facilityCheckInTime")
                            defaults.set(self.currentUser.meetingType, forKey: "SavedMeetingType")
                        }else{
                            defaults.set(formatter.string(from: Date()), forKey: "meetingCheckInTime")
                            defaults.set(self.currentUser.meetingType, forKey: "SavedMeetingType")
                        }
                        defaults.synchronize()
                        
                    }
                    else {
                        defaults.removeObject(forKey: "SavedMeetingType")
                        defaults.removeObject(forKey: "STORED_MEETING_NAME")
                        defaults.removeObject(forKey: "meetingCheckInTime")
                        
                    }
                    
                    defaults.synchronize()
                    
                    //self.tableView.reloadData()
                }
                
                let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                alertTitle += " Error";
                let errorMessage = "An error occurred while saving your meeting record. Your meeting was not recorded, please try again.";
                let alert = UIAlertController(title: alertTitle, message: errorMessage, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                    self.sendBlankRequest(isCheckIn, isMeeting: isMeeting)
                }))
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension TestStatusDashboardViewController : UITextViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollHintView.alpha != 0 && !isScrollHintViewAnim {
            isScrollHintViewAnim = true
            
            UIView.animate(withDuration: 0.4, animations: {
                self.scrollHintView.alpha = 0
            }) { _ in
                self.isScrollHintViewAnim = false
            }
        }
    }
}
