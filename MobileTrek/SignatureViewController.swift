//
//  SignatureViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/2/18.
//  Copyright © 2018 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD

class SignatureViewController: UIViewController {

    @IBOutlet weak var signatureView: SignatureView!
    @IBOutlet weak var signHereImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var helpTextLabel: UILabel!

    @objc var attendanceUploadURLKey: String?
    @objc var selfieUploadURLKey: String?
    @objc var formUploadURLKey: String?
    
    var platform = Platform.shared()
    var progressHud: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()

        signatureView.delegate = self

        initializeLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
          navigationController?.navigationBar.barStyle = .default
    }

    func initializeLayout() {
        self.navigationItem.hidesBackButton = true

        clearButton.alpha = 0
        submitButton.alpha = 0
        clearButton.backgroundColor = Graphics.primaryColor
        submitButton.backgroundColor = Graphics.primaryColor

        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    @IBAction func clearBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Clear Signature",
                                      message: "Are you sure you want to clear the signature?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.toggleSubmitClearButtons(hide: true)
            self.signatureView.clear()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func submitBtnClicked(_ sender: Any) {
        submitButton.isEnabled = false

        submitButton.isHidden = true
        clearButton.isHidden = true
        helpTextLabel.isHidden = true

        if let sigScreenShot = signatureView.getSignatureAsImage() {
            let newImageSize = CGSize(width: sigScreenShot.size.width / 2,
                                      height: sigScreenShot.size.height / 2)
            let alterImage = Graphics.scaleImage(sigScreenShot, newSize: newImageSize)
            if let imgData = alterImage.jpegData(compressionQuality: 0.9) {
                checkIn(signatureUploadURLKey: imgData.base64EncodedString())
            }
        }
        else {
            BFLog("Raw screenshot is nil")
        }
    }

    func toggleSubmitClearButtons(hide: Bool) {
        if hide {
            helpTextLabel.isHidden = false

            UIView.animate(withDuration: 0.4, animations: {
                self.submitButton.alpha = 0
                self.clearButton.alpha = 0
            }) { _ in
                self.submitButton.isHidden = true
                self.clearButton.isHidden = true

                UIView.animate(withDuration: 0.4, animations: {
                    self.helpTextLabel.alpha = 1
                })
            }
        }
        else {
            submitButton.isHidden = false
            clearButton.isHidden = false

            UIView.animate(withDuration: 0.4, animations: {
                self.helpTextLabel.alpha = 0
            }) { _ in
                self.helpTextLabel.isHidden = true

                UIView.animate(withDuration: 0.4, animations: {
                    self.submitButton.alpha = 1
                    self.clearButton.alpha = 1
                })
            }
        }
    }

    func checkIn(signatureUploadURLKey: String?) {
        progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHud?.label.text = "Uploading..."

        let alertTitle = (platform.checkinorout == "checkin") ? "Meeting Check-In" : "Meeting Check-Out"

        let checkInOutReq = NTCheckInOutRequest(baseUrl: platform.baseUrl,
                                                participantId: platform.globalPartId,
                                                pin: platform.globalPin,
                                                checkInType: platform.checkInType,
                                                action: platform.checkinorout,
                                                gpsLat: platform.globalLat,
                                                gpsLong: platform.globalLng,
                                                meetingType: platform.meetingType)

        checkInOutReq.selfie = selfieUploadURLKey ?? ""
        checkInOutReq.attendance = attendanceUploadURLKey ?? ""
        checkInOutReq.signature = signatureUploadURLKey ?? ""

        checkInOutReq.sendRequest { response in
            if (response == "success" || self.platform.checkInType == "facility") {
                DispatchQueue.main.async {
                    self.progressHud?.hide(animated: true)
                }

                if self.platform.checkinorout == "checkin" {
                    let defaults = UserDefaults.standard
                    let timeStamp = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy h:mm a"

                    BFLog("Date TimeStamp = \(formatter.string(from: timeStamp))")

                    if self.platform.meetingCheckIn && !self.platform.meetingCheckOut {
                        let defaults = UserDefaults.standard
                        defaults.removeObject(forKey: "SavedMeetingType")
                        defaults.removeObject(forKey: "STORED_MEETING_NAME")
                        defaults.removeObject(forKey: "meetingCheckInTime")
                        defaults.synchronize()
                    }
                    else {
                        if self.platform.checkInType == "facilitycheckincheckout" {
                            defaults.set(formatter.string(from: timeStamp), forKey: "facilityCheckInTime")
                            defaults.set(self.platform.meetingType, forKey: "SavedMeetingType")
                        }else{
                            defaults.set(formatter.string(from: Date()), forKey: "meetingCheckInTime")
                            defaults.set(self.platform.meetingType, forKey: "SavedMeetingType")
                        }
                        defaults.synchronize()
                    }

                    defaults.synchronize()
                }
                else {
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: "SavedMeetingType")
                    defaults.removeObject(forKey: "STORED_MEETING_NAME")
                    defaults.removeObject(forKey: "meetingCheckInTime")
                    defaults.synchronize()
                }

                let alert = UIAlertController(title: alertTitle, message: response, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    let mtrekMenu = self.storyboard?.instantiateViewController(withIdentifier: "mtrekmenu") as! MTrekMenuViewController
                    mtrekMenu.isFromCheckInOut = true
                    //self.navigationController?.pushViewController(mtrekMenu, animated: true)
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                print("Server response: " + response)
                let errorMessage = "An error occurred while saving your meeting record. Your meeting was not recorded, please try again."
                let alert = UIAlertController(title: alertTitle, message: errorMessage, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
                    DispatchQueue.main.async {
                        let mtrekMenu = self.storyboard?.instantiateViewController(withIdentifier: "mtrekmenu") as! MTrekMenuViewController
                        mtrekMenu.isFromCheckInOut = true
                        //self.navigationController?.pushViewController(mtrekMenu, animated: true)
                        self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                    }
                }))

                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                    self.checkIn(signatureUploadURLKey: signatureUploadURLKey)
                }))

                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension SignatureViewController : SignatureViewDelegate {

    func signStatusChanged(isSigned: Bool) {
        toggleSubmitClearButtons(hide: !isSigned)
    }
}
