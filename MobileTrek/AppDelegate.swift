//
//  AppDelegate.swift
//  MobileTrek
//
//  Created by Steven Fisher on 11/15/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import SharkORM
import IQKeyboardManagerSwift
class AppDelegate: UIResponder, UIApplicationDelegate, SRKDelegate {
	
	/*
     cell.selectedIcon.image = UIImage(named: "checked")
     }else{
     cell.selectedIcon.image = UIImage(named: "unchecked")
		Used for pulling a Navigation Controller from the
		Navigation Stack when the user is logged out.
	*/
	internal var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {		
		Bugfender.activateLogger("Qvd6gOo5lzEy181sQPHXOZ9kNdi4L3nz")
		IQKeyboardManager.shared.enable = true
		let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:31c1f25b-b13f-4f71-a39e-a1cf78a7872a")
		let defaultServiceConfig = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
		AWSServiceManager.default().defaultServiceConfiguration = defaultServiceConfig
        
        SharkORM.setDelegate(self)
        SharkORM.openDatabaseNamed("BACTestResults")
		
		return true
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		checkForInvalidSession()
	}
	
	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		attemptVersionCheck { result in
			completionHandler(result)
		}
	}
    func loadHome(){
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let landingPage : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "testStatusDash") as! TestStatusDashboardViewController
        let navigationController = UINavigationController()
        navigationController.viewControllers = [landingPage]
        window?.rootViewController = navigationController
    }
    func loadLogin(){
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let landingPage : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "loginViewController") as! ViewController
        let navigationController = UINavigationController()
        navigationController.viewControllers = [landingPage]
        window?.rootViewController = navigationController
    }
	/*
		Checks the user defaults everytime the application is brought to
		the foreground to see if the session time has past 1 hour. If it
		has then the user will be brought back to the login ViewController.
	*/
	private func checkForInvalidSession() {
		let defaults = UserDefaults.standard
		
		if let loginSession = defaults.string(forKey: "loginSession"),
			defaults.bool(forKey: "hasAgreed") {
			let date = Date()
			
			let formatter = DateFormatter()
			formatter.dateFormat = "MM-dd-yyyy HH:mm"
			
			if let dateFromLogin = formatter.date(from: loginSession),
				let hours = Calendar.current.dateComponents([.hour], from: dateFromLogin, to: date).hour {
				if hours >= 1 {
					// Session time has elapsed, time to kick the user out
					logoutUser(userDefaults: defaults)
				}
			}
			else {
				// Unable to create a date object from the login session
				// This could be due to a bad date. Log out the user.
				logoutUser(userDefaults: defaults)
			}
		}
	}
	
	private func attemptVersionCheck(closure: @escaping (UIBackgroundFetchResult) -> Void) {
		NTAppSupport().sendRequest { latestVersionSupported in
			let kLatestVersion: String = "LATEST_VERSION_SUPPORTED"
			
			if let latestVersion = latestVersionSupported {				
				let defaults = UserDefaults.standard
				
				if let latestVersionLocal = defaults.string(forKey: kLatestVersion),
					latestVersionLocal == latestVersion {
					closure(.noData)
				}
				else {
					defaults.set(latestVersion, forKey: kLatestVersion)
					defaults.synchronize()
					
					closure(.newData)
				}
			}
			else {
				closure(.failed)
			}
		}
	}
	
	/*
		Logs out the user by removing the login session var from UserDefaults.
		This will also pop the ViewController to the login ViewController.
		
		- parameter userDefaults: UserDefaults used to remove login session info
								  and synchronizes.
	*/
	private func logoutUser(userDefaults: UserDefaults) {
		userDefaults.removeObject(forKey: "loginSession")
		userDefaults.removeObject(forKey: "hasContinued")
		userDefaults.synchronize()
		
		if let win = window,
			let rootVC = win.rootViewController,
			let navController = rootVC as? UINavigationController {
			
			// Goto login controller
			let viewController = navController.storyboard?.instantiateViewController(withIdentifier: "loginViewController")
			
			DispatchQueue.main.async {
				navController.pushViewController(viewController!, animated: true)
			}
		}
	}
	
}
