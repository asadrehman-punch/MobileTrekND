//
//  CollectionSiteViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 7/19/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import MapKit

class CollectionSiteViewController: UIViewController, CLLocationManagerDelegate {

	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var cityStateZipLabel: UILabel!
	@IBOutlet weak var callButton: UIButton!
	@IBOutlet weak var directionsButton: UIButton!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var bottomFrameView: UIView!
	@IBOutlet weak var actionContainerView: UIView!
	
	private var locationManager: CLLocationManager!
	private var receivedLocation: Bool = false
	private var locationPlacemark: MKPlacemark!
	private var combinedAddress: String = ""
	private var cityStateZip: String = ""
	private var fullSearchAddress: String = ""
	private var didInit: Bool = false
	
	var location: RTLocations!
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.startUpdatingLocation()
		
		initializeLayout()
		
		if location.phones.count > 0 {
			for i in 0...location.phones.count - 1 {
				location.phones[i] = parseAndCleanPhoneNumber(location.phones[i])
			}
		}
		else {
			callButton.isHidden = true
		}
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if !didInit {
			didInit = true
			
			Graphics.addBorder(view: actionContainerView, position: .top)
			Graphics.addBorder(view: callButton, position: .right)
		}
	}
	
    override func viewDidAppear(_ animated: Bool) {
          navigationController?.navigationBar.barStyle = .default
    }
	// MARK: - CLLocationManagerDelegate
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let _ = locations.first {
			manager.stopUpdatingLocation()
			
			if !receivedLocation {
				geocodeAndMoveMapWithAddress(fullSearchAddress, mapView: mapView)
				receivedLocation = true
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		showStandardAlert("Location Error", message: error.localizedDescription)
	}
	
	// MARK: - IBAction & Selectors
	
	@IBAction func closeButton_Clicked(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func callButton_Clicked(_ sender: UIButton) {
		if location.phones.count == 1 {
			let phone = location.phones[0]
			
			let alert = UIAlertController(title: "", message: "Call \(phone)", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			let callAction = UIAlertAction(title: "Call", style: .default, handler: { action in
				let phoneNumber = "tel://\(phone)"
				UIApplication.shared.open(URL(string: phoneNumber)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
			})
			
			alert.addAction(cancelAction)
			alert.addAction(callAction)
			
			DispatchQueue.main.async(execute: {
				self.present(alert, animated: true, completion: nil)
			})
		}
		else if location.phones.count > 0 {
			let alert = UIAlertController(title: "Call", message: "Select a phone number", preferredStyle: .actionSheet)
			
			for phone in location.phones {
				let pAction = UIAlertAction(title: phone, style: .default, handler: { action  in
					// Call number
					let phoneNumber = URL(string: "tel://" + self.parseAndCleanPhoneNumber(phone))!
					UIApplication.shared.open(phoneNumber, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
				})
				
				alert.addAction(pAction)
			}
			
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			alert.addAction(cancelAction)
			
			DispatchQueue.main.async(execute: {
				self.present(alert, animated: true, completion: nil)
			})
		}
	}
	
	@IBAction func directionsButton_Clicked(_ sender: UIButton) {
		let mapItem = MKMapItem(placemark: locationPlacemark)
		let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
		let currentLocationMapItem = MKMapItem.forCurrentLocation()
		let didOpenMaps = MKMapItem.openMaps(with: [currentLocationMapItem, mapItem], launchOptions: launchOptions)
		BFLog("Did open maps = \(didOpenMaps)")
	}
	
	// MARK: - Class Functions
	
	private func initializeLayout() {
		directionsButton.isEnabled = false
		
		self.navigationItem.title = location.name
		self.view.backgroundColor = Graphics.backgroundColor
		
		let shadowPath = UIBezierPath(rect: self.bottomFrameView.bounds)
		bottomFrameView.layer.masksToBounds = false
		bottomFrameView.layer.shadowColor = UIColor.black.cgColor
		bottomFrameView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
		bottomFrameView.layer.shadowOpacity = 0.5
		bottomFrameView.layer.shadowPath = shadowPath.cgPath
		
		combinedAddress = location.address1 + " " + location.address2
		cityStateZip = location.city + ", " + location.state + ", " + location.zip
		fullSearchAddress = combinedAddress + cityStateZip
		
		BFLog("Full Search Address = \(fullSearchAddress)")
		
		addressLabel.text = combinedAddress
		cityStateZipLabel.text = cityStateZip
		
		self.navigationController?.navigationBar.tintColor = UIColor.white
	}
	
	fileprivate func parseAndCleanPhoneNumber(_ phoneNumber: String) -> String {
		var fixedStr = phoneNumber
		fixedStr.insert("-", at: fixedStr.index(fixedStr.startIndex, offsetBy: 3))
		fixedStr.insert("-", at: fixedStr.index(fixedStr.startIndex, offsetBy: 7))
		return fixedStr
	}
	
	fileprivate func geocodeAndMoveMapWithAddress(_ address: String, mapView: MKMapView) {
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(address) { placemarks, error in
			if let err = error {
				self.showStandardAlert("Geocoder Error", message: err.localizedDescription)
			}
			else if let pms = placemarks {
				var savedPlacemark: CLPlacemark!
				
				if pms.count > 0 {
					for p in pms {
						savedPlacemark = p
						break
					}
					
					self.locationPlacemark = MKPlacemark(placemark: savedPlacemark)
					let region = MKCoordinateRegion.init(center: (savedPlacemark.location?.coordinate)!, latitudinalMeters: 500, longitudinalMeters: 500)
					
					self.directionsButton.isEnabled = true
					
					let anno = CTSKAnnotation(coordinate: region.center)
					mapView.setRegion(region, animated: true)
					mapView.addAnnotation(anno)
				}
			}
			else {
				self.showStandardAlert("Geocoder Error", message: "Unable to set placemarker")
			}
		}
	}
	
	fileprivate func showStandardAlert(_ title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(okAction)
		
		DispatchQueue.main.async {
			self.present(alert, animated: true, completion: nil)
		}
	}

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
