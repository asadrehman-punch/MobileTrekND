//
//  FormPictureController.swift
//  MobileTrek
//
//  Created by Karthik Navuluri on 4/25/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD

class FormPictureController: UIViewController {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backCameraView: CTSKInlineCameraView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var backFrameView: UIView!
     private var progressHud: MBProgressHUD? = nil
    var platform = Platform.shared()
    @objc var selfieUploadURLKey: String?
    @objc var isAttendanceRequired: Bool = false
    @objc var isSignatureRequired: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLayout()
        
        backCameraView.initializeCameraWithFrontCamera(false, withVideo: false)
        backCameraView.showLiveCameraPreview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
          navigationController?.navigationBar.barStyle = .black
    }
    @IBAction func checkInButton_Tapped(_ sender: Any) {
        submitButton.isEnabled = false
        
        backCameraView.capturePicture { image in
            self.backCameraView.disconnectCameraPreview()
            
            if let imgData = image.jpegData(compressionQuality: 0.9) {
                let encodedImgStr = imgData.base64EncodedString()
                
                
                if self.isAttendanceRequired{
                    let attendanceView = self.storyboard?.instantiateViewController(withIdentifier: "attendanceView") as! AttendanceViewController
                    attendanceView.isSignatureRequired = self.isSignatureRequired
                    attendanceView.formUploadURLKey = encodedImgStr
                    attendanceView.selfieUploadURLKey = self.selfieUploadURLKey
                    self.navigationController?.pushViewController(attendanceView, animated: true)
                }
                else if self.isSignatureRequired {
                    let signatureView = self.storyboard?.instantiateViewController(withIdentifier: "signatureView") as! SignatureViewController
                    signatureView.formUploadURLKey = encodedImgStr
                    signatureView.selfieUploadURLKey = self.selfieUploadURLKey
                    self.navigationController?.pushViewController(signatureView, animated: true)
                }
                else {
                    self.checkIn(formUploadURLKey: encodedImgStr)
                }
            }
        }
    }
    
    func initializeLayout() {
        self.view.backgroundColor = Graphics.backgroundColor
        submitButton.backgroundColor = Graphics.primaryColor
        
        backFrameView.backgroundColor = Graphics.backgroundColor
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func takeTimeStampForDefaults() {
        let defaults = UserDefaults.standard
        let timeStamp = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        if platform.checkInType == "facilitycheckincheckout" {
            defaults.set(formatter.string(from: timeStamp), forKey: "facilityCheckOutTime")
            defaults.synchronize()
        }
        else {
            defaults.set(formatter.string(from: timeStamp), forKey: "meetingCheckOutTime")
            defaults.removeObject(forKey: "SavedMeetingType")
            defaults.removeObject(forKey: "STORED_MEETING_NAME")
            defaults.removeObject(forKey: "meetingCheckInTime")
            defaults.synchronize()
        }
    }
    
    func checkIn(formUploadURLKey: String?) {
        progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHud?.label.text = "Uploading"
        let alertTitle = (platform.checkInType == "checkin" ) ? "Meeting Check-In" : platform.checkInType == "facilitycheckincheckout" ? "Collection Site Check-In/Out" : "Meeting Check-Out"
        
        let checkInOutReq = NTCheckInOutRequest(baseUrl: platform.baseUrl,
                                                participantId: platform.globalPartId,
                                                pin: platform.globalPin,
                                                checkInType: platform.checkInType,
                                                action: platform.checkinorout,
                                                gpsLat: platform.globalLat,
                                                gpsLong: platform.globalLng,
                                                meetingType: platform.meetingType)
        
        checkInOutReq.selfie = selfieUploadURLKey ?? ""
        checkInOutReq.form = formUploadURLKey ?? ""
        
        checkInOutReq.sendRequest { response in
            self.progressHud?.hide(animated: true)
            if (response == "success" || self.platform.checkInType == "facilitycheckincheckout") {
                self.takeTimeStampForDefaults()
                
                if self.platform.checkinorout == "checkin" {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy h:mm a"
                    
                    let defaults = UserDefaults.standard
                    if self.platform.checkInType == "facilitycheckincheckout" {
                        defaults.set(formatter.string(from: Date()), forKey: "facilityCheckInTime")
                        defaults.set(self.platform.meetingType, forKey: "SavedMeetingType")
                    }else{
                        defaults.set(formatter.string(from: Date()), forKey: "meetingCheckInTime")
                        defaults.set(self.platform.meetingType, forKey: "SavedMeetingType")
                    }
                    defaults.synchronize()
                }
                
                let alert = UIAlertController(title: alertTitle, message: response, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
  //                  let mtrekMenu = self.storyboard?.instantiateViewController(withIdentifier: "mtrekmenu") as! MTrekMenuViewController
                    //mtrekMenu.dash = true
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
//                    self.navigationController?.pushViewController(mtrekMenu, animated: true)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let errorMessage = "An error occurred while saving your meeting record. Your meeting was not recorded, please try again."
                let alert = UIAlertController(title: alertTitle, message: errorMessage, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
                    DispatchQueue.main.async {
                        let mtrekMenu = self.storyboard?.instantiateViewController(withIdentifier: "mtrekmenu") as! MTrekMenuViewController
                        //mtrekMenu.dash = true
                        //self.navigationController?.pushViewController(mtrekMenu, animated: true)
                        self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                    self.checkIn(formUploadURLKey: formUploadURLKey)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

