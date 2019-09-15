//
//  WarningInfoViewController.swift
//  MobileTrek
//
//  Created by Asad Rehman khan on 05/09/2019.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit

class WarningInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.navigationController?.navigationItem.leftBarButtonItem = nil
        self.navigationController?.navigationItem.backBarButtonItem = nil
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
