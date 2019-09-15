//
//  NearestCollectionSitesViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 7/14/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class NearestCollectionSitesViewController: BaseViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var sideMenu: SideMenuController!
	private let currentUserPlatform = Platform.shared()
	private var headerView: UIView!
	private var headerLabel: UILabel!
	private var locationManager: CLLocationManager!
	private var locationsRec = [RTLocations]()
	private var currentRadius: String = "20"
	private var settingsBarButton: UIBarButtonItem!
	private var progressHud: MBProgressHUD?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        sideMenu.delegate = self
        sideMenu.sitesSelected()
		initializeLayout()
		
		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		
		// Request location permission
		locationManager.requestWhenInUseAuthorization()
		
		// Update location
		fetchCollectionSites("20")
		
		tableView.delegate = self
		tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColorNavBar()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.topItem?.title = "Collection Sites"
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        settingsBarButton = createRightBarButtonItem(UIImage(named: "settings_cog")!, selector: #selector(openSiteSettings(_:)))
        self.navigationItem.rightBarButtonItem = settingsBarButton
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		  navigationController?.navigationBar.barStyle = .default
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.navigationItem.title = nil
		self.tabBarController?.navigationItem.rightBarButtonItem = nil
	}
	
	// MARK: - IBAction & Selector
	
	@objc func openSiteSettings(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Search Radius", message: "Please select a radius to search around your current location.", preferredStyle: .actionSheet)
		let radius20 = UIAlertAction(title: "20 miles", style: .default) { action in self.fetchCollectionSites("20") }
		let radius25 = UIAlertAction(title: "25 miles", style: .default) { action in self.fetchCollectionSites("25") }
		let radius30 = UIAlertAction(title: "30 miles", style: .default) { action in self.fetchCollectionSites("30") }
		let customRadius = UIAlertAction(title: "Custom...", style: .default) { action in self.showCustomRadiusDialog() }
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alert.addAction(radius20)
		alert.addAction(radius25)
		alert.addAction(radius30)
		alert.addAction(customRadius)
		alert.addAction(cancelAction)
		
		alert.popoverPresentationController?.sourceView = self.view
		alert.popoverPresentationController?.barButtonItem = settingsBarButton
		
		self.present(alert, animated: true, completion: nil)
	}
	
	// MARK: - CLLocationManagerDelegate
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations.last
		
		if let loc = location {
			let lat = String(loc.coordinate.latitude)
			let lng = String(loc.coordinate.longitude)
			
			BFLog("GPS Lat = \(lat)")
			BFLog("GPS Lng = \(lng)")
			
			// Send request
			let request = NTCollectionSiteRequest(baseUrl: currentUserPlatform.baseUrl, gpsLat: lat, gpsLng: lng, distance: currentRadius)
			request.sendRequest { message, collectionSites in
				self.progressHud?.hide(animated: true)
				
				if let sites = collectionSites {
					if self.locationsRec.count > 0 {
						self.locationsRec.removeAll()
						self.tableView.reloadData()
					}
					
					if sites.count > 0 {
						self.locationsRec = [RTLocations](sites)
						self.locationsRec.sort(by: { (loc1, loc2) -> Bool in
							loc1.distance < loc2.distance
						})
						self.tableView.reloadData()
						
						DispatchQueue.main.async(execute: { 
							self.headerLabel.text = "The following sites are based on a \(self.currentRadius) mile radius around your current location."
						})
					}
					else {
						self.locationsRec.removeAll()
						self.tableView.reloadData()
						
						DispatchQueue.main.async(execute: { 
							self.headerLabel.text = "No locations were found within \(self.currentRadius) miles of your current location."
						})
					}
				}
				else {
					self.locationsRec.removeAll()
					self.tableView.reloadData()
					
					DispatchQueue.main.async(execute: { 
						self.headerLabel.text = "No locations were found within \(self.currentRadius) miles of your current location."
					})
					
					BFLog("Unable to get collection sites: \(message)")
					self.showStandardAlert("Collection Sites Error", message: message, okClicked: nil)
				}
			}
			
			manager.stopUpdatingLocation()
		}
	}
	
	// MARK: - UITableViewDelegate
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		headerView = UIView(frame: CGRect.zero)
		headerView.backgroundColor = Graphics.backgroundColor
		
		headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.bounds.size.width, height: headerView.bounds.size.height))
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		headerLabel.textAlignment = .center
		headerLabel.font = UIFont.systemFont(ofSize: 15)
		headerLabel.textColor = UIColor.darkGray
		headerLabel.numberOfLines = 0
		
		headerView.addSubview(headerLabel)
		
		let horizontalFormat = "H:|-[headerLabel]-|"
		let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: horizontalFormat, options: [], metrics: nil, views: ["headerLabel": headerLabel])
		headerView.addConstraints(horizontalConstraints)
		
		let verticalFormat = "V:|-[headerLabel]-|"
		let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: verticalFormat, options: [], metrics: nil, views: ["headerLabel": headerLabel])
		headerView.addConstraints(verticalConstraints)
		
		return headerView
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return locationsRec.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: NearestMeetingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NearestMeetingsTableViewCell", for: indexPath) as! NearestMeetingsTableViewCell
		
		let curLocation = locationsRec[indexPath.row]
		
		if let name = curLocation.name {
			cell.locationNameLabel.text = name
			
			if let distance = curLocation.distance {
				cell.distanceLabel.text = String(distance) + " miles"
				cell.distanceLabel.isHidden = false
			}
			else {
				cell.distanceLabel.isHidden = true
			}
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let collectionSite = self.storyboard?.instantiateViewController(withIdentifier: "collectionSiteViewController") as! CollectionSiteViewController
		collectionSite.location = locationsRec[indexPath.row]
		
		self.navigationController?.pushViewController(collectionSite, animated: true)
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// MARK: - Helper Functions

	fileprivate func initializeLayout() {
		self.navigationController?.navigationBar.tintColor = UIColor.white
	}
	
	fileprivate func createRightBarButtonItem(_ image: UIImage, selector: Selector) -> UIBarButtonItem {
		let reRenderImage = image.withRenderingMode(.alwaysTemplate)
		
		let button = UIButton(type: .custom)
		button.setImage(reRenderImage, for: UIControl.State())
		button.frame = CGRect(x: 0, y: 0, width: reRenderImage.size.width, height: reRenderImage.size.height)
		button.addTarget(self, action: selector, for: .touchUpInside)
		
		let barItem = UIBarButtonItem(customView: button)
		return barItem
	}
	
	fileprivate func showCustomRadiusDialog() {
		let alert = UIAlertController(title: "Custom Radius", message: "Enter a custom radius to search for collection locations.", preferredStyle: .alert)
		
		let doneAction = UIAlertAction(title: "Done", style: .default) { action in
			if let textFields = alert.textFields,
				let text = textFields[0].text {
				let convText: Int? = Int(text)
				
				if let nRadius = convText , nRadius > 0 && nRadius <= 300 {
					self.fetchCollectionSites(text)
				}
				else {
					alert.resignFirstResponder()
					
					self.showStandardAlert("Invalid Radius", message: "Radius must be between 0 and 300!", okClicked: {
						DispatchQueue.main.async(execute: { 
							self.present(alert, animated: true, completion: nil)
						})
					})
				}
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alert.addAction(doneAction)
		alert.addAction(cancelAction)
		
		alert.addTextField { textField in
			textField.keyboardType = .numberPad
		}
		
		self.present(alert, animated: true, completion: nil)
	}
	
	fileprivate func fetchCollectionSites(_ radius: String) {
		BFLog("Fetching collection sites with radius \(radius)")
		
		if CLLocationManager.authorizationStatus() == .denied {
			showDeniedLocationAlert()
			return
		}
		
		progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
		progressHud?.label.text = "Loading..."
		
		currentRadius = radius
		locationManager.startUpdatingLocation()
	}
	
	fileprivate func showStandardAlert(_ title: String, message: String, okClicked:(()->())?) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default) { action in
			okClicked?()
		}
		alert.addAction(okAction)
		
		present(alert, animated: true, completion: nil)
	}
	
	fileprivate func showDeniedLocationAlert() {
		BFLog("Failed to get location")
		
		DispatchQueue.main.async(execute: {
			self.headerLabel.text = "Failed to get your location."
		})
		
		progressHud?.hide(animated: true)
		
		self.locationsRec.removeAll()
		self.tableView.reloadData()
		
		let alert = UIAlertController(title: "Error", message: "Failed to get your location. To continue please allow location permissions through the iOS Settings Application", preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		let settingsAction = UIAlertAction(title: "Settings", style: .default) { action in
			UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
		}
		
		alert.addAction(cancelAction)
		alert.addAction(settingsAction)
		
		DispatchQueue.main.async { 
			self.present(alert, animated: true, completion: nil)
		}
	}

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
extension NearestCollectionSitesViewController : SideMenuDelegate{
    func surveyTapped() {
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    func testStatusTapped() {
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "testStatusDash") as! TestStatusDashboardViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func mettingTapped() {
        // Do nothing as it is on the required page
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "checkInOutDash") as! CheckInOutDashboardViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func sitesTapped() {
        //        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "nearestColSitesView") as! NearestCollectionSitesViewController
        //        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func bacTestTapped() {
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "bacDash") as! BACTestDashboardViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func supportTapped() {
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "supportView") as! SupportViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func logoutTapped() {
        //        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController")
        //        self.navigationController?.pushViewController(loginVC!, animated: false)
        AppStateManager.sharedInstance.loadLogin()
    }
    
}
