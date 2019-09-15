//
//  SupportViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/17/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class SupportViewController: BaseViewController {

	@IBOutlet weak var agreementButton: UIButton!
    @IBOutlet weak var sideMenu: SideMenuController!
	@IBOutlet weak var billingHeaderLabel: UILabel!
	@IBOutlet weak var testingHeaderLabel: UILabel!
	@IBOutlet weak var agreementHeaderLabel: UILabel!
    @IBOutlet weak var videoCallButton: UIButton!
	
	fileprivate let currentUser = Platform.shared()
    
    var isFromLogin: Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        sideMenu.delegate = self
        setSelected()
		initializeLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColorNavBar()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.topItem?.title = "Support"
        
        if !isFromLogin && currentUser.monitoring {
            videoCallButton.isHidden = false
        }
        setNeedsStatusBarAppearanceUpdate()
    }
	override func viewDidAppear(_ animated: Bool) {
        
          navigationController?.navigationBar.barStyle = .default
		
	}
    
   
	
	@IBAction func monitoringClicked(_ sender: AnyObject) {
		let centralVC = self.storyboard?.instantiateViewController(withIdentifier: "centralVC")
		
		DispatchQueue.main.async {
			self.navigationController?.pushViewController(centralVC!, animated: true)
		}
	}
	
	@IBAction func viewAgreementClick(_ sender: AnyObject) {
		let agreementVC = self.storyboard?.instantiateViewController(withIdentifier: "agreementViewController") as! AgreementViewController
		agreementVC.isStoppingBy = true
		self.navigationController?.pushViewController(agreementVC, animated: true)
	}
	
	@IBAction func billing(_ sender: AnyObject) {
		let launchUrl = "mailto:billing@recoverytrek.com"
		UIApplication.shared.open(URL(string: launchUrl)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
	}
	
	@IBAction func phoneClicked(_ sender: AnyObject) {
		let alert = UIAlertController(title: "", message: "Call 757-943-9800", preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let callAction = UIAlertAction(title: "Call", style: .default, handler: { action in
			let phoneNumber = "tel://7579439800"
			UIApplication.shared.open(URL(string: phoneNumber)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
		})
		
		alert.addAction(cancelAction)
		alert.addAction(callAction)
		
		DispatchQueue.main.async(execute: {
			self.present(alert, animated: true, completion: nil)
		})
	}
	
	@IBAction func openEmail(_ sender: AnyObject) {
		let launchUrl = "mailto:greatsupport@recoverytrek.com"
		UIApplication.shared.open(URL(string: launchUrl)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
	}
	
	@IBAction func sendFeedback_Clicked(_ sender: AnyObject) {
		let sb = UIStoryboard(name: "Feedback", bundle: nil)
		let feedbackVC = sb.instantiateViewController(withIdentifier: "feedbackVC") as! FeedbackViewController
        feedbackVC.isFromLogin = isFromLogin
		self.navigationController?.pushViewController(feedbackVC, animated: true)
	}
	
	private func initializeLayout() {
		// Get agreement timestamp
		let defaults = UserDefaults.standard
		if let timestamp = defaults.string(forKey: "agreementTimestamp") {
			agreementButton.setTitle(timestamp, for: UIControl.State())
		}
	}
    func setSelected(){
        sideMenu.supportSelected()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
extension SupportViewController : SideMenuDelegate{
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
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "bacDash") as! BACTestDashboardViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func supportTapped() {
        //        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "supportView") as! SupportViewController
        //        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func logoutTapped() {
        //        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController")
        //        self.navigationController?.pushViewController(loginVC!, animated: false)
        AppStateManager.sharedInstance.loadLogin()
    }
    
}
