//
//  BACTestDashboardViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/12/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class BACTestDashboardViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    
	@IBOutlet weak var historyTableView: UITableView!
	@IBOutlet weak var sideMenu: SideMenuController!
    
	fileprivate let currentUser = Platform.shared()
	
	// MARK: - Overridden Functions
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColorNavBar()
        UIApplication.shared.statusBarStyle = .default
        sideMenu.delegate = self
        setSelected()
        navigationController?.navigationBar.isHidden = false
		historyTableView.delegate = self
		historyTableView.dataSource = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupColorNavBar()
        UIApplication.shared.statusBarStyle = .default
        
        self.navigationController?.navigationBar.topItem?.title = "BAC Test"
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        setupColorNavBar()
		// Set back button text for the next screens to blank
		self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		self.navigationItem.hidesBackButton = true
          navigationController?.navigationBar.barStyle = .default
	}

	// MARK: - IBAction Handlers
	
	@IBAction func startBACButton_Clicked(_ sender: UIButton) {
		let bacTestSB = UIStoryboard(name: "BacTesting", bundle: nil)
		
		let prebacchecklist = bacTestSB.instantiateViewController(withIdentifier: "prebacchecklist") as! PreBACCheckListViewController
		prebacchecklist.showBracLevel = currentUser.showBracLevel
		prebacchecklist.showBracResult = currentUser.showBracResult
		self.navigationController?.pushViewController(prebacchecklist, animated: true)
	}
	
	// MARK: - UITableView Delegate
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if currentUser.globalBacTestHistory {
			return currentUser.bacTestHistory!.count
		}
		else {
			return 0
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if currentUser.globalBacTestHistory {
			return 1
		}
		else {
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "BAC Test History"
		}
		else {
			return ""
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as? ButtonTableViewCell {
			cell.titleLabel.text = currentUser.bacTestHistory![indexPath.row].importedDate
			return cell
		}
		else {
			let cell = ButtonTableViewCell()
			cell.titleLabel.text = currentUser.bacTestHistory![indexPath.row].importedDate
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "historyVC") as! HistoryViewController
		historyVC.vcTitle = "BAC Test History"
		var tempData = [String]()
		tempData.append("Completed: \(currentUser.bacTestHistory![indexPath.row].submittedDate)")
		tempData.append("Uploaded: \(currentUser.bacTestHistory![indexPath.row].importedDate)")
		
		if let bacResult = currentUser.bacTestHistory![indexPath.row].bracResult {
			tempData.append("BAC Result: \(bacResult)")
		}
		
		if let bacLevel = currentUser.bacTestHistory![indexPath.row].bracLevel {
			tempData.append("BAC Level: \(bacLevel)")
		}
		historyVC.data = tempData
		self.navigationController?.pushViewController(historyVC, animated: true)
	}
    func setSelected(){
        sideMenu.bacTestSelected()
    }
	
}
extension BACTestDashboardViewController : SideMenuDelegate{
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
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "nearestColSitesView") as! NearestCollectionSitesViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func bacTestTapped() {
        //        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "bacDash") as! BACTestDashboardViewController
        //        self.navigationController?.pushViewController(mtrekmenu, animated: false)
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
