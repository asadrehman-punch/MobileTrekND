//
//  MarsBacViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 10/24/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD
import AVFoundation

class MarsBacViewController: UIViewController {

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
	@IBOutlet weak var frameViewBottomConstraint: NSLayoutConstraint!
	
	fileprivate let platformUser = Platform.shared()
	private var locationManager = CLLocationManager()
	fileprivate var selfieImage = UIImage()
	fileprivate var bacManager: MarsBacManager!
	fileprivate var gpsLat: String = ""
	fileprivate var gpsLong: String = ""
	fileprivate var calculatedBacLevel: String = ""
	fileprivate var calculatedBacResult: String = ""
	fileprivate var didRunProgressAnim: Bool = false
	private var didInit: Bool = false
	private var progressHud: MBProgressHUD? = nil
	fileprivate var isTesting: Bool = false
	fileprivate var videoPath: String = ""
    fileprivate var btWasDisconnected: Bool = false
	
	@objc var showBacResult: Bool = false
	@objc var showBacLevel: Bool = false
	@objc var willUseVideo: Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		progressView.borderColor = Graphics.primaryColor
		progressView.dividerColor = Graphics.primaryColor
		progressView.progressColor = Graphics.progressColor
		
		continueButton.backgroundColor = Graphics.primaryColor
		
		self.view.backgroundColor = Graphics.backgroundColor
		
		self.navigationItem.hidesBackButton = true
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
            if CLLocationManager.authorizationStatus() == .authorizedAlways
                || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                initialize()
            }
            else {
                showPermissionsDeniedAlert()
            }
        }
        else {
            showPermissionsDeniedAlert()
        }
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if !didInit {
			didInit = true
			
			backCameraView.initializeCameraWithFrontCamera(true, withVideo: willUseVideo)
		}
	}
	
	// MARK: - Selectors
	
	@objc func didEnterBackground() {
		if isTesting {
			isTesting = false
			bacManager.disconnectDevice()
			
			gotoMenu(bacFailureReason: .appclosed)
		}
	}
	
	@IBAction func continueBtnTapped(_ sender: Any) {
		gotoMenu()
	}
	
	@IBAction func cancelButton_Clicked(_ sender: Any) {
		if isTesting {
			let alert = UIAlertController(title: "Cancel Test", message: "Are you sure you want to cancel your test?", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
			alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
				self.isTesting = false
				self.bacManager.disconnectDevice()
				
				self.gotoMenu()
			}))
			
			self.present(alert, animated: true, completion: nil)
		}
		else {
			gotoMenu()
		}
	}
	
	// MARK: - Class Functions
    
    private func initialize() {
        bacManager = MarsBacManager(delegate: self)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
    }
    
    private func showPermissionsDeniedAlert() {
        let alert = UIAlertController(title: "Permissions Required", message: "Camera and Location permissions are required in order to perform a BAC test. Please enable the permissions in the MobileTrek app settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            self.gotoMenu()
        }))
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(settingsUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
	
    fileprivate func gotoMenu(bacFailureReason: MTrekMenuViewController.BACFailureReason? = nil) {
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "mtrekmenu") as! MTrekMenuViewController
		vc.bacFailReason = bacFailureReason
		vc.isFromBACTest = true
		
		self.navigationController?.pushViewController(vc, animated: true)
	}
	
	fileprivate func takePicture() {
		backCameraView.capturePicture { image in
			self.selfieImage = image
		}
	}
	
	fileprivate func sendRequest() {
		DispatchQueue.main.async {
			self.progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
			self.progressHud?.label.text = "Uploading..."
		}
		
		if willUseVideo {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "MM_dd_yyyy-HH_mm_ss"
//
//            let dateNow = Date()
//            let dtStr = formatter.string(from: dateNow)
			
//            let uploadKey = "\(platformUser.globalProgramId)/\(bacTest.partId)/\(dtStr).mp4"
//            let vidUrl = "https://s3.amazonaws.com/rt-mobiletrek/\(uploadKey)"
			
//            AWSUploader.uploadRequest(uploadKey: uploadKey, filePath: videoPath, canStream: false, progress: nil, finished: {
//                DispatchQueue.main.async {
//                    self.progressHud?.hide(animated: true)
//                }
//                
//                bacTest.videoUrl = vidUrl
//                
//                NTBacTestRequest(bacTest: bacTest).sendRequest({ success, message in
//                    if success {
//                        let alert = UIAlertController(title: "Upload Successful", message: "Your test was uploaded successfully.", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                    else {
//                        let alert = UIAlertController(title: "Test Not Uploaded", message: "Test failed to upload due to error: \(message)", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                })
//            })
		}
		else {
            let alert = UIAlertController(title: "Test Not Uploaded", message: "This device is no longer supported.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
//            NTBacTestRequest(bacTest: bacTest).sendRequest { success, message in
//                DispatchQueue.main.async {
//                    self.progressHud?.hide(animated: true)
//                }
//
//                if success {
//                    let alert = UIAlertController(title: "Upload Successful", message: "Your test was uploaded successfully.", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//                    self.present(alert, animated: true, completion: nil)
//                }
//                else {
//                    let alert = UIAlertController(title: "Test Not Uploaded", message: "Test failed to upload due to error: \(message)", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
		}
	}
}

// MARK: - CLLocationManagerDelegate

extension MarsBacViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		let alert = UIAlertController(title: "Error Retreiving Location", message: "Please go to settings and check to make sure location services are enabled for MobileTrek.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		
		self.present(alert, animated: true, completion: nil)
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		manager.stopUpdatingLocation()
		
		if let firstLoc = locations.first {
			let coord = CLLocationCoordinate2DMake(firstLoc.coordinate.latitude, firstLoc.coordinate.longitude)
			
			gpsLat = String(coord.latitude)
			gpsLong = String(coord.longitude)
		}
	}
}

// MARK: - MarsBacManagerDelegate

extension MarsBacViewController: MarsBacManagerDelegate {
	
	func deviceConnected() {
		isTesting = true
		
		DispatchQueue.main.async {
			self.connectionView.isHidden = true
			self.testFrameView.isHidden = false
			
			self.backCameraView.showLiveCameraPreview()
		}
	}
	
	func deviceDisconnected() {
		if isTesting {
			DispatchQueue.main.async {
				self.backCameraView.disconnectCameraPreview()
				self.testFrameView.isHidden = true
				self.bottomFrameView.isHidden = true
			}
			
			let alert = UIAlertController(title: "Device Disconnected", message: "The device was disconnected during testing. The test is no longer valid. Please try again.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
				self.gotoMenu()
			}))
			
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func blow() {
		self.progressView.resetProgress()
		
		DispatchQueue.main.async {
			self.statusLabel.text = "Blow Now"
			self.silOutline.isHidden = false
			
			self.progressView.isHidden = false
		}
	}
	
	func blowTick() {
		if !didRunProgressAnim {
			didRunProgressAnim = true
			
			self.progressView.setProgress(1.0, animationDuration: 4, completion: nil)
			
			if willUseVideo {
				backCameraView.startVideoRecording()
			}
			else {
				DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
					self.takePicture()
				})
			}
		}
	}
	
	func analyzingData() {
		DispatchQueue.main.async {
			self.statusLabel.text = "Analyzing results"
			self.progressView.setLoadingAnimation()
		}
		
		if willUseVideo {
			backCameraView.stopVideoRecordingAndPausePreview(false)
			videoPath = backCameraView.finalVideoPath
		}
	}
	
	func results(bac: Float) {
		isTesting = false
		bacManager.disconnectDevice()
		
		DispatchQueue.main.async {
			self.silOutline.isHidden = true
			self.progressView.isHidden = true
			self.progressView.resetProgress()
			
			self.calculatedBacLevel = String(bac)
			
			if self.showBacLevel || self.showBacResult {
				if bac >= 0.01 {
					if self.showBacLevel {
						self.bacResultLabel.text = "Results: \(String(format: "%.02f", bac)) BAC"
					}
					else {
						self.bacResultLabel.isHidden = true
					}
					
					if self.showBacResult {
						self.bacPosNegLabel.text = "Positive"
						self.bacPosNegLabel.textColor = UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1)
					}
					else {
						self.bacPosNegLabel.isHidden = true
					}
				}
				else {
					if self.showBacLevel {
						self.bacResultLabel.text = "Results: 0.00 BAC"
					}
					else {
						self.bacResultLabel.isHidden = true
					}
					
					if self.showBacResult {
						self.bacPosNegLabel.text = "Negative"
						self.bacPosNegLabel.textColor = UIColor(red: 0.298, green: 0.851, blue: 0.392, alpha: 1)
					}
					else {
						self.bacPosNegLabel.isHidden = true
					}
				}
			}
			else {
				self.bacResultLabel.text = "Test Complete"
				self.bacResultLabel.isHidden = false
			}
			
			self.continueButton.isHidden = false;
			self.continueButton.alpha = 1;
			
			self.bottomFrameView.isHidden = false
		}
		
		self.calculatedBacLevel = String(format: "%.02f", bac)
		self.calculatedBacResult = (bac >= 0.01) ? "Positive" : "Negative"
		
		UIView.animate(withDuration: 0.4) {
			self.testFrameView.alpha = 0
		}
		
		self.view.layoutIfNeeded()
		
		UIView.animate(withDuration: 0.4) {
			self.frameViewBottomConstraint.constant += self.continueButton.frame.size.height;
			
			self.view.layoutIfNeeded()
		}
		
//        var encodedImg: String? = nil
//
//        if !willUseVideo {
//            let convData = selfieImage.jpegData(compressionQuality: 0.9)!
//            encodedImg = convData.base64EncodedString()
//        }
//
//        let bacTest = BACTest(participantInfo: 0,
//                              programURL: platformUser.baseUrl,
//                              partId: platformUser.globalPartId,
//                              partPin: platformUser.globalPin,
//                              gpsLat: gpsLat,
//                              gpsLong: gpsLong,
//                              bracLevel: calculatedBacLevel,
//                              bracResult: calculatedBacResult,
//                              submitted: String(Int(Date().timeIntervalSince1970)),
//                              bacDeviceId: nil) // TODO: Set Bacdevice id for Mars
//
//        if CTSKNetworking.connectedToNetwork() {
//            sendRequestWith(bacTest: bacTest)
//        }
//        else {
//            let dbManager = DatabaseManager()
//            dbManager.insertBacTest(from: bacTest)
//        }
	}
	
	func blowError() {
		isTesting = false
		
		DispatchQueue.main.async {
			self.backCameraView.disconnectCameraPreview()
			
			self.progressView.isHidden = true
			self.progressView.resetProgress()
			
			self.silOutline.isHidden = true
			self.testFrameView.isHidden = true
		}
		
		let alert = UIAlertController(title: "BAC Error", message: "Blow error detected. Please test again and provide a full breath.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
			self.gotoMenu()
		}))
		
		self.present(alert, animated: true, completion: nil)
	}
    
    func bluetoothConnected() {
        DispatchQueue.main.async {
            self.connectionLabel.text = "Press and HOLD the power button on the BAC device to turn it on"
            self.bluetoothImageView.isHidden = true
            self.deviceImage.isHidden = false
        }
    }
    
    func bluetoothDisconnected() {
        if isTesting {
            self.isTesting = false
            self.bacManager.disconnectDevice()
            
            self.gotoMenu(bacFailureReason: .btdisconnect)
        }
        else {
            DispatchQueue.main.async {
                self.connectionLabel.text = "Please enable Bluetooth"
                self.bluetoothImageView.isHidden = false
                self.deviceImage.isHidden = true
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
