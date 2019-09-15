//
//  StartViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/17/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class StartViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let defaults = UserDefaults.standard
		
		if defaults.bool(forKey: "hasAgreed") {
			defaults.removeObject(forKey: "loginSession")
			defaults.synchronize()
			
			let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController")
			self.pushViewController(loginVC!, animated: true)
		}
		else {
			let agreementVC = self.storyboard?.instantiateViewController(withIdentifier: "agreementViewController")
			self.pushViewController(agreementVC!, animated: true)
		}
    }

}
