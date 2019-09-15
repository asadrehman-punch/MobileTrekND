//
//  BaseViewController.swift
//  MobileTrek
//
//  Created by E Apple on 6/24/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationController?.navigationBar.isHidden = false
        
    }
    func setupColorNavBar(){
        let font = UIFont.systemFont(ofSize: 18)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:UIColor.black]
        self.navigationController?.navigationBar.barStyle = .black
//        if let font = UIFont(name: "SFCompactText-Medium", size: 18){
//            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:UIColor(red: 255/255, green: 149/255, blue: 0, alpha: 1.0)]
//            self.navigationController?.navigationBar.barStyle = .black
//        }
        
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.98, green:0.98, blue:0.99, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        self.navigationItem.leftBarButtonItem = nil
    }
    
    
    
    func setupTransparentNavBar(){
        
        let font = UIFont.systemFont(ofSize: 18)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:UIColor.black]
        self.navigationController?.navigationBar.barStyle = .black
        
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
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
