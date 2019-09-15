//
//  MTrekMenuViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/17/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class MTrekMenuViewController: UITabBarController {
	
	fileprivate var currentIndex: Int = 0
	fileprivate var vcs = [UIViewController]()
	fileprivate let currentUser = Platform.shared()
	fileprivate var returnCheckInOutIndex = -1
	fileprivate var returnBacTestIndex = -1
	fileprivate var returnSupportIndex = -1
	
	@objc var isFromCheckInOut: Bool = false
	@objc var isFromBACTest: Bool = false
	@objc var isFromSupport: Bool = false
    var bacFailReason: BACFailureReason? = nil
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add logout button
		let logoutNavbarItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout_Clicked(_:)))
		//self.navigationItem.leftBarButtonItem = logoutNavbarItem
		
		// Tint the tab bar selected item
		UITabBar.appearance().tintColor = Graphics.primaryColor
		
        if bacFailReason != nil {
            displayBACFailedAlert()
            
            bacFailReason = nil
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Clear view controllers
		vcs = [UIViewController]()

		var indexer = 0

		// Add tab items if they are enabled
		if addObjectIfAvailable(currentUser.checkDailyStatus, storyboardId: "testStatusDash") {
			indexer += 1
		}

		let isFacilityCheckInAvailable = (currentUser.collectionSiteCheckIn || currentUser.collectionSiteCheckOutLocation || currentUser.collectionSiteCheckInSelfie)
		let isFacilityCheckOutAvailable = (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckOutLocation || currentUser.collectionSiteCheckOutSelfie)
		let isMeetingCheckInAvailable = (currentUser.meetingCheckIn || currentUser.meetingCheckInLocation || currentUser.meetingCheckInSelfie)
		let isMeetingCheckOutAvailable = (currentUser.meetingCheckOut || currentUser.meetingCheckOutLocation || currentUser.meetingCheckOutSelfie || currentUser.meetingAttendance || currentUser.meetingSignature)
		
		if isFacilityCheckInAvailable || isFacilityCheckOutAvailable || isMeetingCheckInAvailable || isMeetingCheckOutAvailable {
			if addObjectIfAvailable(true, storyboardId: "checkInOutDash") {
				indexer += 1
				returnCheckInOutIndex = indexer
			}
		}
		else {
			_ = addObjectIfAvailable(false, storyboardId: "checkInOutDash")
		}

		if addObjectIfAvailable(currentUser.nearestCollectionLocations, storyboardId: "nearestColSitesView") {
			indexer += 1
		}

		if addObjectIfAvailable(currentUser.alcoholBACTest, storyboardId: "bacDash") {
			indexer += 1
			returnBacTestIndex = indexer
		}

		if addObjectIfAvailable(currentUser.support, storyboardId: "supportView") {
			indexer += 1
			returnSupportIndex = indexer
		}

		// Set the view controllers of the tab controller
		self.setViewControllers(vcs, animated: false)

		if isFromCheckInOut {
			// If the user returns from checkin/out
			self.selectedIndex = returnCheckInOutIndex - 1
		}
		else if isFromBACTest {
			// If the user returns from bactesting
			self.selectedIndex = returnBacTestIndex - 1
		}
		else if isFromSupport {
			self.selectedIndex = returnSupportIndex - 1
		}

        // Need to reset the var incase the VC is still in nav stack
        isFromCheckInOut = false
        isFromBACTest = false
        isFromSupport = false
	}
	
	@objc func logout_Clicked(_ sender: UIBarButtonItem) {
		let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController")
		self.navigationController?.pushViewController(loginVC!, animated: true)
	}
	
	private func addObjectIfAvailable(_ isEnabled: Bool, storyboardId: String) -> Bool {
		if isEnabled {
			let viewController = self.storyboard?.instantiateViewController(withIdentifier: storyboardId)
			vcs.append(viewController!)
			
			return true
		}
		
		return false
	}
	
	private func displayBACFailedAlert() {
        guard let bacFail = bacFailReason else {
            return
        }
        
        var message = ""
        
        switch bacFail {
        case .appclosed: message = "Your test was cancelled due to closing the app. Please continue by retesting."
        case .btdisconnect: message = "Your test was cancelled because the bluetooth connection was disconnected."
        }
        
		let alert = UIAlertController(title: "BAC Test Cancelled", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		
		self.present(alert, animated: true, completion: nil)
	}
    
    enum BACFailureReason {
        case appclosed
        case btdisconnect
    }
}
