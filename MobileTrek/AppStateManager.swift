//
//  AppStateManager.swift
//  MobileTrek
//
//  Created by E Apple on 6/18/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit

class AppStateManager: NSObject {
    //MARK:- Singleton
    static let sharedInstance = AppStateManager()
    
    
    
    //    var isguest : Bool!
    
    //MARK:- Properties
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
    
    //MARK:- Class Methods
    private override init() {
        super.init()
        
        
        
    }
    
    //MARK:- Helper Methods
    func markUserLogout(){
        
        self.changeRootViewController()
    }
    
    func changeRootViewController(){
        
    }
    func loadHome(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.loadHome()
    }
    func loadLogin(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.loadLogin()
    }
}
enum BACFailureReason {
    case appclosed
    case btdisconnect
}
