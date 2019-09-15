//
//  CheckInLocationViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 7/14/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class CheckInLocationViewController: UIViewController, CLLocationManagerDelegate {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var backFrameView: UIView!
	
	fileprivate var locationManager: CLLocationManager!
	fileprivate var currentUserPlatform = Platform.shared()
	
	var isSelfieRequired: Bool = false
    var isAttendanceRequired: Bool = false
    var isSignatureRequired: Bool = false 
	var isMeeting: Bool = false
    var isFormRequired: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
		
		currentUserPlatform.checkinorout = "checkin"
		
		initializeLayout()
		
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		
		// Request location permission
		locationManager.requestWhenInUseAuthorization()
		
		// Update location
		locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .black
         self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = Graphics.primaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
      //  self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
    }
	
	@IBAction func nextButton_Tapped(_ sender: UIButton) {
		if isSelfieRequired  {
			// Go to check in selfie
			let checkInSelfie = self.storyboard?.instantiateViewController(withIdentifier: "checkInSelfie") as! CheckInSelfieViewController
			checkInSelfie.isMeeting = isMeeting
            checkInSelfie.isAttendanceRequired = isAttendanceRequired
            checkInSelfie.isSignatureRequired = isSignatureRequired
            checkInSelfie.isFormPictureRequired = isFormRequired
			self.navigationController?.pushViewController(checkInSelfie, animated: true)
		}
        else if isFormRequired{
            let formView = self.storyboard?.instantiateViewController(withIdentifier: "formCheckInView") as! FormPictureController
            formView.isSignatureRequired = isSignatureRequired
            self.navigationController?.pushViewController(formView, animated: true)
        }
        else if isAttendanceRequired{
            let attendanceView = self.storyboard?.instantiateViewController(withIdentifier: "attendanceView") as! AttendanceViewController
            attendanceView.isSignatureRequired = isSignatureRequired
            self.navigationController?.pushViewController(attendanceView, animated: true)
        }
        else if isSignatureRequired {
            let checkInSignature = self.storyboard?.instantiateViewController(withIdentifier: "signatureView") as! SignatureViewController
            self.navigationController?.pushViewController(checkInSignature, animated: true)
        }
		else {
			checkIn()
		}
	}
	
	private func initializeLayout() {
		self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = Graphics.primaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		
		nextButton.backgroundColor = Graphics.primaryColor
		backFrameView.backgroundColor = UIColor.white
	}
    
    override func viewWillAppear(_ animated: Bool) {
       // setupColorNavBar()
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Graphics.primaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		let alert = UIAlertController(title: "Error", message: "Failed to get your location. To continue please allow location permissions through the iOS Settings Application", preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK", style: .default) { action in
			_ = self.navigationController?.popViewController(animated: true)
		}
		
		let settingsAction = UIAlertAction(title: "Settings", style: .default) { action in
			UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
		}
		
		alert.addAction(okAction)
		alert.addAction(settingsAction)
		
		self.present(alert, animated: true, completion: nil)
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let firstLocation = locations.first {
			manager.stopUpdatingLocation()
			
			let currentLocation = firstLocation
			BFLog("didUpdateToLocation = \(firstLocation)")
			
			let coord = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude,
			                                   longitude: currentLocation.coordinate.longitude)
			
			currentUserPlatform.globalLat = String(coord.latitude)
			currentUserPlatform.globalLng = String(coord.longitude)
			
			let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
			let region = MKCoordinateRegion(center: coord, span: span)
			
			mapView.showsUserLocation = true
			mapView.mapType = .hybrid
			mapView.setRegion(region, animated: false)
		}
	}
	
	fileprivate func checkIn() {
       // let alertTitle = (currentUserPlatform.checkinorout == "checkin") ? "Meeting Check-In" : "Meeting Check-Out"

        let alertTitle = (currentUserPlatform.checkInType == "checkin" ) ? "Meeting Check-In" : currentUserPlatform.checkInType == "facilitycheckincheckout" ? "Collection Site Check-In/Out" : "Meeting Check-Out"

		let request = NTCheckInOutRequest(baseUrl: currentUserPlatform.baseUrl, participantId: currentUserPlatform.globalPartId,
		                                  pin: currentUserPlatform.globalPin, checkInType: currentUserPlatform.checkInType,
		                                  action: currentUserPlatform.checkinorout, gpsLat: currentUserPlatform.globalLat,
		                                  gpsLong: currentUserPlatform.globalLng, meetingType: currentUserPlatform.meetingType)
		
		request.sendRequest { (message) in
			BFLog("CheckInOut Completed. Response = \(message)")
            BFLog("Checkin Type: \(self.currentUserPlatform.checkInType)")
            if (message == "success" || self.currentUserPlatform.checkInType == "facilitycheckincheckout") {
//                DispatchQueue.main.async {
//                    self.progressHud?.hide(animated: true)
//                }

                if self.currentUserPlatform.checkinorout == "checkin" {
                    let defaults = UserDefaults.standard
                    let timeStamp = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy h:mm a"

                    BFLog("Date TimeStamp = \(formatter.string(from: timeStamp))")

                    if self.currentUserPlatform.meetingCheckIn && !self.currentUserPlatform.meetingCheckOut {
                        let defaults = UserDefaults.standard
                        defaults.removeObject(forKey: "SavedMeetingType")
                        defaults.removeObject(forKey: "STORED_MEETING_NAME")
                        defaults.removeObject(forKey: "meetingCheckInTime")
                        defaults.synchronize()
                    }
                    else {
                        if self.currentUserPlatform.checkInType == "facilitycheckincheckout" {
                            defaults.set(formatter.string(from: timeStamp), forKey: "facilityCheckInTime")
                            defaults.set(self.currentUserPlatform.meetingType, forKey: "SavedMeetingType")
                        }else{
                            defaults.set(formatter.string(from: Date()), forKey: "meetingCheckInTime")
                            defaults.set(self.currentUserPlatform.meetingType, forKey: "SavedMeetingType")
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

                let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    let mtrekMenu = self.storyboard?.instantiateViewController(withIdentifier: "mtrekmenu") as! MTrekMenuViewController
                    if (self.currentUserPlatform.checkInType == "facilitycheckincheckout"){
                        mtrekMenu.isFromCheckInOut = false
                    }else{
                        mtrekMenu.isFromCheckInOut = true
                    }
//                    self.navigationController?.pushViewController(mtrekMenu, animated: true)
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else {
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
                    self.checkIn()
                }))

                self.present(alert, animated: true, completion: nil)
            }
        }
	}
	
	fileprivate func takeTimeStampForDefaults() {
		let defaults = UserDefaults.standard
		let timeStamp = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "MM/dd/yyyy h:mm a"
		
		BFLog("Date TimeStamp = \(formatter.string(from: timeStamp))")
		
		if currentUserPlatform.checkInType == "facilitycheckincheckout" {
			defaults.set(formatter.string(from: timeStamp), forKey: "facilityCheckInTime")
			defaults.synchronize()
		}
		else {
			defaults.set(formatter.string(from: timeStamp), forKey: "meetingCheckInTime")
			defaults.synchronize()
		}
	}

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
