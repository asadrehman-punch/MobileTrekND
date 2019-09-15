//
//  BreathConnectorViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 9/17/18.
//  Copyright © 2018 RecoveryTrek. All rights reserved.
//

import UIKit
import AVFoundation

class BreathConnectorViewController: BaseViewController {

    @IBOutlet weak var frameViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var backCameraView: CTSKInlineCameraView!
    @IBOutlet weak var bottomFrameView: UIView!
    @IBOutlet weak var testFrameView: UIView!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var bacResultLabel: UILabel!
    @IBOutlet weak var bacPosNegLabel: UILabel!
    @IBOutlet weak var progressView: CTSKProgressView!
    @IBOutlet weak var silOutline: UIImageView!
    @IBOutlet weak var bluetoothImageView: UIImageView!
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var batteryLowView: UIView!
    
    private var locationManager: CLLocationManager!
    private var bluetoothManager: CBCentralManager?
    var mBacTrack: BacTrackAPI!
    var isTesting = false
    var isCountDownAnimPlayed = false
    var isBlowAnimPlayed = false
    var isExpectedDisconnect = false
    var isNewBACDevice = false
    var flagDeviceInvalid = false
    var btToggleFlag = false
    var isDeviceFound = false
    var isOfflineTest = false
    var isInitialized = false
    var gpsLat = "0"
    var gpsLong = "0"
    var platformUser = Platform.shared()
    var calculatedBacLevel = "0.00"
    var calculatedBacResult = "Negative"
    @objc var showBacResult = false
    @objc var showBacLevel = false
    @objc var willUseVideo = false
    var mediaFilePath = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        mBacTrack = BacTrackAPI(delegate: self, andAPIKey: "7dae569100e74d07928444985e9058")
        mBacTrack.delegate = self

        progressView.borderColor = Graphics.primaryColor
        progressView.dividerColor = Graphics.primaryColor
        progressView.progressColor = Graphics.progressColor

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColorNavBar()
        
        self.navigationController?.navigationBar.topItem?.title = "Self BAC"
        self.navigationController?.navigationBar.isHidden = false
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupColorNavBar()
        // Set back button text for the next screens to blank
         navigationController?.navigationBar.barStyle = .default
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isInitialized {
            self.view.backgroundColor = Graphics.backgroundColor

          //  self.navigationController?.navigationBar.barTintColor = Graphics.primaryColor
           // self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            connectionView.backgroundColor = Graphics.primaryColor
            continueButton.backgroundColor = Graphics.primaryColor
            bottomFrameView.backgroundColor = Graphics.backgroundColor
            testFrameView.backgroundColor = Graphics.backgroundColor
            statusLabel.textColor = UIColor.white

            bottomFrameView.alpha = 0
            testFrameView.alpha = 0

            isInitialized = true
            
            Graphics.addRoundedCorners(view: batteryLowView, corners: .allCorners, radius: 15.0)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        isExpectedDisconnect = true
        mBacTrack.disconnect()

        UIApplication.shared.isIdleTimerDisabled = false
    }

    @IBAction func continueBtnTapped() {
        gotoMenu()
    }

    func initializeBluetooth() {
        if bluetoothManager == nil {
            bluetoothManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        }

        centralManagerDidUpdateState(bluetoothManager!)
    }

    func gotoMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mtrekMenuVC = storyboard.instantiateViewController(withIdentifier: "mtrekmenu") as! MTrekMenuViewController
        mtrekMenuVC.isFromBACTest = true

        self.navigationController?.pushViewController(mtrekMenuVC, animated: true)
    }

    func takePicture(completed: @escaping () -> Void) {
        backCameraView.capturePicture { image in
            self.backCameraView.disconnectCameraPreview()
            
            // Create file path
            let fileName = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            var fileUrl = URL(fileURLWithPath: fileName)
            fileUrl.appendPathComponent("bactestpic.jpeg")

            self.mediaFilePath = fileUrl.path

            // Remove existing file
            let fm = FileManager.default
            if fm.fileExists(atPath: fileUrl.path) {
                try? fm.removeItem(atPath: fileUrl.path)
            }
            
            // Write the new image
            let imageData = image.jpegData(compressionQuality: 1)!
            try! imageData.write(to: fileUrl)
            
            print("Wrote image to = \(fileUrl)")
            
            completed()
        }
    }

    @objc func cancelTesting(sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Cancel Testing",
            message: "Are you sure you want to cancel this test?",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.isTesting = false
            self.isExpectedDisconnect = true

            self.mBacTrack.disconnect()

            self.gotoMenu()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    func calculateBacResult(_ finalBacResult: CGFloat) -> [String] {
        if finalBacResult >= 0.01 {
            return ["Positive", String(format: "%.02f", finalBacResult)]
        }

        return ["Negative", String(format: "%.02f", 0.00)]
    }

    func checkIfAudioServicesAllowed() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .denied:
            displayPermissionDeniedAlert(permissionName: "Microphone")

        case .authorized:
            if bluetoothManager == nil {
                initializeBluetooth()
            }

        case .restricted:
            displayPermissionRestrictedAlert(permissionName: "Microphone")

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    if self.bluetoothManager == nil {
                        self.initializeBluetooth()
                    }
                }
                else {
                    self.displayPermissionDeniedAlert(permissionName: "Microphone")
                }
            }
        }
    }

    func checkIfCameraServicesAllowed() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            checkIfAudioServicesAllowed()

        case .denied:
            displayPermissionDeniedAlert(permissionName: "Camera")

        case .restricted:
            displayPermissionRestrictedAlert(permissionName: "Camera")

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.checkIfAudioServicesAllowed()
                }
                else {
                    self.displayPermissionDeniedAlert(permissionName: "Camera")
                }
            }
        }
    }

    func displayPermissionDeniedAlert(permissionName: String) {
        let permString = "\(permissionName) permission"
        let alertMessage = "\(permissionName)s are required in order to perform a BAC test. Please update these permissions in app settings."

        let alert = UIAlertController(title: permString, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(settingsUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }

    func displayPermissionRestrictedAlert(permissionName: String) {
        let permString = "\(permissionName) permission"
        let alertMessage = "\(permString)s are restricted. Please make sure that parental controls are disabled in order to perform a BAC test."

        let alert = UIAlertController(title: permString, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
    }

    func displayRequestResponseAlert(message: String) {
        let alert = UIAlertController(title: "BAC Upload Result", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func displayAlert(title: String, message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))

        self.present(alert, animated: true, completion: nil)
    }
}

extension BreathConnectorViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            BFLog("authorizedWhenInUse")
            checkIfCameraServicesAllowed()

        case .denied:
            BFLog("denied")
            displayPermissionDeniedAlert(permissionName: "Location")

        case .notDetermined:
            BFLog("notDetermined")
            manager.requestWhenInUseAuthorization()

        case .authorizedAlways:
            BFLog("authorizedAlways")
            checkIfCameraServicesAllowed()

        case .restricted:
            BFLog("restricted")
            displayPermissionRestrictedAlert(permissionName: "Location")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        if let currentLocation = locations.last {
            let coord = CLLocationCoordinate2D(
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude)

            gpsLat = String(coord.latitude)
            gpsLong = String(coord.longitude)
        }
        else {
            BFLog("Unable to grab current location")

            gpsLat = "0"
            gpsLong = "0"
        }

        mBacTrack.connectToNearestBreathalyzer()

        // Strobe connect
        UIView.animate(withDuration: 1, delay: 3, options: [.repeat, .autoreverse], animations: {
            self.connectionLabel.alpha = 0.2
        }, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Error retrieving location", message: "Please go to settings and check to make sure location services are enabled for MobileTrek", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.present(alert, animated: true) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension BreathConnectorViewController: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .resetting:
            BFLog("CBState = resetting")

        case .unauthorized:
            BFLog("CBState = Unauthorized")

        case .unknown:
            BFLog("CBState = Unknown")

        case .unsupported:
            BFLog("CBState = Unsupported")

            displayAlert(
                title: "Bluetooth Unsupported",
                message: "Bluetooth LE is not supported on this device, please use a phone that is capable of bluetooth LE.",
                completion: nil)

        case .poweredOff:
            BFLog("CBState = Powered Off")

            if isDeviceFound {
                let alert = UIAlertController(title: "Device Disconnected", message: "The device was disconnected during testing. The test is no longer valid. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    if !self.isExpectedDisconnect {
                        self.navigationController?.popViewController(animated: true)
                    }
                }))

                self.present(alert, animated: true) {
                    self.backCameraView.disconnectCameraPreview()

                    UIView.animate(withDuration: 0.4, animations: {
                        self.bottomFrameView.alpha = 0
                        self.testFrameView.alpha = 0
                    })
                }
            }

            if !btToggleFlag {
                statusLabel.text = "Press the power button on your device."

                UIView.animate(withDuration: 0.4, animations: {
                    self.bluetoothImageView.alpha = 0
                }) { _ in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.deviceImage.alpha = 1
                    })
                }
            }

        case .poweredOn:
            BFLog("CBState = Powered On")
            if btToggleFlag {
                statusLabel.text = "Press the power button on your device."

                UIView.animate(withDuration: 0.4, animations: {
                    self.bluetoothImageView.alpha = 0
                }) { _ in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.deviceImage.alpha = 1
                    })
                }
            }

            locationManager.startUpdatingLocation()
        }
    }
}

extension BreathConnectorViewController: BacTrackAPIDelegate {

    func bacTrackAPIKeyDeclined(_ errorMessage: String!) {
        BFLog("BACtrack API Key Declined: \(String(describing: errorMessage))")
    }

    func bacTrackFound(_ breathalyzer: Breathalyzer!) {
        isDeviceFound = true

        statusLabel.text = "Connecting to breathalyzer"
        statusLabel.textColor = UIColor.black

        testFrameView.alpha = 1

        BFLog("Attempting to connect to breathalyzer")

        let defaults = UserDefaults.standard
        let curDeviceId = breathalyzer.peripheral.identifier.uuidString

        if breathalyzer.type == .mobile {
            if let retBacTracDeviceUUID = defaults.string(forKey: "bacTrackDeviceUUID") {
                BFLog("Using existing BAC device")

                if curDeviceId == retBacTracDeviceUUID {
                    BFLog("Using valid device")

                    UIView.animate(withDuration: 0.4, animations: {
                        self.deviceImage.alpha = 0
                        self.connectionView.alpha = 0
                        self.testFrameView.alpha = 1
                    }) { _ in
                        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTesting(sender:)))
                        self.navigationItem.leftBarButtonItem = cancelItem

                        DispatchQueue.main.async {
                            self.progressView.setLoadingAnimation()
                        }
                    }
                }
                else {
                    BFLog("Device is unknown")

                    displayAlert(
                        title: "Error connecting device",
                        message: "You already have a registered device connected to this phone. If you are trying to register a new device to this phone please contact RecoveryTrek!") {
                            self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            else {
                BFLog("User has new device")

                isNewBACDevice = true

                defaults.set(curDeviceId, forKey: "bacTrackDeviceUUID")
                defaults.synchronize()

                UIView.animate(withDuration: 0.4, animations: {
                    self.deviceImage.alpha = 0
                    self.connectionView.alpha = 0
                }) { _ in
                    let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTesting(sender:)))
                    self.navigationItem.leftBarButtonItem = cancelItem

                    DispatchQueue.main.async {
                        self.progressView.setLoadingAnimation()
                    }
                }
            }
        }
        else {
            BFLog("User attempted to connect with invalid device: \(breathalyzer.type.rawValue)")
        }
    }

    func bacTrackConnected(_ device: BACtrackDeviceType) {
        guard !flagDeviceInvalid else {
            return
        }

        statusLabel.text = "Successfully connected to breathalyzer"

        backCameraView.initializeCameraWithFrontCamera(true, withVideo: willUseVideo)
        backCameraView.showLiveCameraPreview()
        mBacTrack.startCountdown()
        isTesting = true

        UIApplication.shared.isIdleTimerDisabled = true

        mBacTrack.getBreathalyzerBatteryLevel()

        BFLog("Device connected successfully")
    }

    func bacTrackCountdown(_ seconds: NSNumber!, executionFailure error: Bool) {
        guard !error && !isCountDownAnimPlayed else {
            return
        }

        BFLog("Starting countdown")

        statusLabel.text = "Warming up"
        silOutline.isHidden = false

        progressView.resetProgress()

        if !isCountDownAnimPlayed {
            isCountDownAnimPlayed = true
            DispatchQueue.main.async {
                self.progressView.setProgress(1.0, animationDuration: 12, completion: nil)
            }
        }
    }

    func bacTrackStart() {
        guard !flagDeviceInvalid else {
            mBacTrack.disconnect()
            return
        }

        statusLabel.text = "Start Blowing"
        progressView.resetProgress()

        BFLog("Start blowing")
    }

    func bacTrackBlow() {
        BFLog("blow")
        
        if willUseVideo {
            backCameraView.startVideoRecording()
        }
        else {
            // Flash the screen when we're about to take a picture
            
            // Store the previous brightness value
            let prevBrightness = UIScreen.main.brightness
            
            // Jack up the screen brightness
            UIScreen.main.brightness = 1.0
            
            // Display the FlashView
            flashView.alpha = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.takePicture {
                    // Picture was taken lets hide the FlashView
                    UIView.animate(withDuration: 0.4, animations: {
                        self.flashView.alpha = 0
                    }, completion: { _ in
                        // Lower the screen brightness to the previous value
                        UIScreen.main.brightness = prevBrightness
                    })
                }
            }
        }

        statusLabel.text = "Keep Blowing"

        if !isBlowAnimPlayed {
            DispatchQueue.main.async {
                self.progressView.setProgress(1.0, animationDuration: 4, completion: nil)
            }

            isBlowAnimPlayed = true
        }
    }

    func bacTrackAnalyzing() {
        BFLog("Analyzing Results")

        if willUseVideo {
            backCameraView.stopVideoRecordingAndPausePreview(true)
            mediaFilePath = backCameraView.finalVideoPath
        }

        statusLabel.text = "Analyzing results"

        UIView.animate(withDuration: 0.4) {
            self.silOutline.alpha = 0
        }

        progressView.resetProgress()

        DispatchQueue.main.async {
            self.progressView.setLoadingAnimation()
        }
    }

    func bacTrackResults(_ bac: CGFloat) {
        let results = calculateBacResult(bac)
        calculatedBacResult = results[0]
        calculatedBacLevel = results[1]

        BFLog("Calculated bac result = \(calculatedBacResult)")
        BFLog("Calculated bac level = \(calculatedBacLevel)")

        UIView.animate(withDuration: 0.4) {
            self.testFrameView.alpha = 0
        }

        self.navigationItem.rightBarButtonItem = nil
        isTesting = false
        isExpectedDisconnect = true
        mBacTrack.disconnect()

        if showBacResult {
            var bufferFrame = bacPosNegLabel.frame
            bufferFrame.origin.y = bacResultLabel.frame.origin.y + bacResultLabel.frame.size.height
            bacPosNegLabel.frame = bufferFrame

            if calculatedBacResult == "Positive" {
                bacPosNegLabel.textColor = UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1.0)
                bacPosNegLabel.text = "Positive"
            }
            else {
                bacPosNegLabel.textColor = UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1.0)
                bacPosNegLabel.text = "Negative"
            }

            bacPosNegLabel.isHidden = false
        }

        if showBacLevel {
            bacResultLabel.text = "Results: \(calculatedBacLevel) BAC"
            bacResultLabel.isHidden = false
        }

        if !showBacLevel && !showBacResult {
            bacResultLabel.text = "Testing Complete"
            bacResultLabel.isHidden = false
        }

        if platformUser.requireBACConfirmation && calculatedBacResult == "Positive" {
            displayAlert(
                title: "Test Confirmation",
                message: "Based on the results received, another test is required. Please ait 15 minutes then complete another BAC test.",
                completion: nil)
        }

        continueButton.isHidden = false
        continueButton.alpha = 1

        bottomFrameView.alpha = 1

        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.frameViewBottomConstraint.constant += self.continueButton.frame.size.height
            self.view.layoutIfNeeded()
        }
        
        let timeNow = Date()
        let unixTime = String(Int(timeNow.timeIntervalSince1970))

        // Upload test
        let bacTest = BACTestResult()
        bacTest.programUrl = platformUser.baseUrl
        bacTest.partId = platformUser.globalPartId
        bacTest.partPin = platformUser.globalPin
        bacTest.gpsLat = gpsLat
        bacTest.gpsLong = gpsLong
        bacTest.bracLevel = calculatedBacLevel
        bacTest.bracResult = calculatedBacResult
        bacTest.submitted = unixTime
        bacTest.mediaPath = mediaFilePath
        bacTest.isVideo = willUseVideo
        bacTest.isFacialRecogEnabled = platformUser.bacRecognition
        
        bacTest.upload { message in
            if message == "success" {
                self.displayAlert(title: "BAC Test Uploaded", message: "The BAC test uploaded successfully.", completion: nil)
            }
            else {
                self.displayAlert(title: "BAC Test Saved", message: "The BAC test was saved and will be uploaded when a better connection can be found.", completion: nil)
            }
        }
    }

    func bacTrackDisconnected() {
        guard !flagDeviceInvalid else {
            return
        }

        if isTesting {
            BFLog("Bac device disconnected. is testing.")

            let alert = UIAlertController(
                title: "Device Disconnected",
                message: "The device was disconnected during testing. The test is no longer valid. Please try again.",
                preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
        }
        else {
            BFLog("BAC device disconnected. not testing.")

            if !isExpectedDisconnect {
                BFLog("Bac device was unexpectedly disconnected")

                let alert = UIAlertController(
                    title: "Device Disconnected",
                    message: "The device was unexpectedly disconnected!",
                    preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))

                self.present(alert, animated: true) {
                    self.backCameraView.disconnectCameraPreview()

                    UIView.animate(withDuration: 0.4, animations: {
                        self.testFrameView.alpha = 0
                        self.bottomFrameView.alpha = 0
                    })
                }
            }
        }

        self.navigationItem.hidesBackButton = isOfflineTest
    }

    func bacTrackConnectTimeout() {
        BFLog("BACtrack connection timeout")
    }

    func bacTrackBatteryLevel(_ number: NSNumber!) {
        BFLog("Battery level: \(String(describing: number))")
        
        if number.intValue <= 0 && batteryLowView.alpha == 0 {
            UIView.animate(withDuration: 0.4) {
                self.batteryLowView.alpha = 0.8
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
