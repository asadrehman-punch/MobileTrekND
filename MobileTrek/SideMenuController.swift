//
//  SideMenuController.swift
//  MobileTrek
//
//  Created by E Apple on 6/16/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit
protocol SideMenuDelegate {
    func testStatusTapped()
    func mettingTapped()
    func sitesTapped()
    func bacTestTapped()
    func supportTapped()
    func surveyTapped()
    func logoutTapped()
}
class SideMenuController: UIView {
    var view: UIView!
    var delegate: SideMenuDelegate!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var homeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var homeViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var meetingView: UIView!
    @IBOutlet weak var meetingHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var meetingBottomConst: NSLayoutConstraint!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationHeightConst: NSLayoutConstraint!
    @IBOutlet weak var locationBottomConst: NSLayoutConstraint!
    @IBOutlet weak var bacView: UIView!
    @IBOutlet weak var bacHeightConst: NSLayoutConstraint!
    @IBOutlet weak var bacBottomConst: NSLayoutConstraint!
    @IBOutlet weak var supportView: UIView!
    @IBOutlet weak var supportHeightConst: NSLayoutConstraint!
    @IBOutlet weak var supportBottomConst: NSLayoutConstraint!
    
    
    @IBOutlet weak var surveyHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var surveyBottomConst: NSLayoutConstraint!
    @IBOutlet weak var surveyIcon: UIImageView!
    @IBOutlet weak var mettingIcon: UIImageView!
    @IBOutlet weak var bacTestIcon: UIImageView!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var checkInIcon: UIImageView!
    @IBOutlet weak var testStatusIcon: UIImageView!
    let selectedColor = UIColor(red:0.00, green:0.61, blue:0.98, alpha:1.0)
    let unSelectedColor = UIColor(red:0.56, green:0.56, blue:0.56, alpha:1.0)
    
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup(){
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask
            = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        viewEssentials()
    }
    
    func loadViewFromNib() -> UIView{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    func viewEssentials(){
        if bacFailReason != nil {
            displayBACFailedAlert()
            
            bacFailReason = nil
        }
        toShowView()
    }
    func toShowView(){
        
        // Add tab items if they are enabled
        if (currentUser.checkDailyStatus){
            addObjectIfAvailable(isEnable: currentUser.checkDailyStatus, heightConst: homeViewHeightConstraint, bottomConst: homeViewBottomCons)
            //add the teststatus
            //indexer += 1
        }else{
            addObjectIfAvailable(isEnable: false, heightConst: homeViewHeightConstraint, bottomConst: homeViewBottomCons)
        }
        
        let isFacilityCheckInAvailable = (currentUser.collectionSiteCheckIn || currentUser.collectionSiteCheckOutLocation || currentUser.collectionSiteCheckInSelfie)
        let isFacilityCheckOutAvailable = (currentUser.collectionSiteCheckOut || currentUser.collectionSiteCheckOutLocation || currentUser.collectionSiteCheckOutSelfie)
        let isMeetingCheckInAvailable = currentUser.meetingCheckIn //(currentUser.meetingCheckIn || currentUser.meetingCheckInLocation || currentUser.meetingCheckInSelfie)
        let isMeetingCheckOutAvailable = currentUser.meetingCheckOut//(currentUser.meetingCheckOut || currentUser.meetingCheckOutLocation || currentUser.meetingCheckOutSelfie || currentUser.meetingAttendance || currentUser.meetingSignature)
        
        if isFacilityCheckInAvailable || isFacilityCheckOutAvailable {
            addObjectIfAvailable(isEnable: true, heightConst: homeViewHeightConstraint, bottomConst: homeViewBottomCons)
            // add the "checkInOutDash" in the side menu
            /*if addObjectIfAvailable(true, storyboardId: "checkInOutDash") {
                indexer += 1
                returnCheckInOutIndex = indexer
            }*/
        }
            
        if  isMeetingCheckInAvailable || isMeetingCheckOutAvailable {
            addObjectIfAvailable(isEnable: true, heightConst: meetingHeightConst, bottomConst: meetingBottomConst)
        }
        else {
            addObjectIfAvailable(isEnable: false, heightConst: meetingHeightConst, bottomConst: meetingBottomConst)
            //_ = addObjectIfAvailable(false, storyboardId: "checkInOutDash")
        }
        
        if (currentUser.nearestCollectionLocations){
            addObjectIfAvailable(isEnable: true, heightConst: locationHeightConst, bottomConst: locationBottomConst)
            //add location in the side menu
            //indexer += 1
        }
        else{
            addObjectIfAvailable(isEnable: false, heightConst: locationHeightConst, bottomConst: locationBottomConst)
            //dont add the location in the side menu
        }
        
        if (currentUser.alcoholBACTest){
            addObjectIfAvailable(isEnable: currentUser.alcoholBACTest, heightConst: bacHeightConst, bottomConst: bacBottomConst)
            //add bacTest in side menu
            
        }
        else{
            addObjectIfAvailable(isEnable: false, heightConst: bacHeightConst, bottomConst: bacBottomConst)
        }
        if (currentUser.support){
            addObjectIfAvailable(isEnable: currentUser.support, heightConst: supportHeightConst, bottomConst: supportBottomConst)
            // add support in the view
        
        }
        else{
            addObjectIfAvailable(isEnable: false, heightConst: supportHeightConst, bottomConst: supportBottomConst)
        }
        
        if currentUser.survey{
             addObjectIfAvailable(isEnable: currentUser.survey, heightConst: surveyHeightConst, bottomConst: surveyBottomConst)
        }else{
            addObjectIfAvailable(isEnable: false, heightConst: surveyHeightConst, bottomConst: surveyBottomConst)
        }
        
        if isFromCheckInOut {
            // If the user returns from checkin/out
//            self.selectedIndex = returnCheckInOutIndex - 1
        }
        else if isFromBACTest {
            // If the user returns from bactesting
//            self.selectedIndex = returnBacTestIndex - 1
        }
        else if isFromSupport {
//            self.selectedIndex = returnSupportIndex - 1
        }
        
        // Need to reset the var incase the VC is still in nav stack
        isFromCheckInOut = false
        isFromBACTest = false
        isFromSupport = false
    }
    func addObjectIfAvailable(isEnable: Bool, heightConst: NSLayoutConstraint, bottomConst: NSLayoutConstraint){
        if (isEnable){
            heightConst.constant = 35
            bottomConst.constant = 16
        }
        else{
            heightConst.constant = 0
            bottomConst.constant = 0
        }
        self.view.layoutIfNeeded()
    }
    func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
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
        topViewController()!.present(alert, animated: true){}
//        self.present(alert, animated: true, completion: nil)
    }
    
    enum BACFailureReason {
        case appclosed
        case btdisconnect
    }
    @IBAction func testStatusTapped(_ sender: Any) {
        //        testStatusSelected()
        delegate.testStatusTapped()
        
    }
    @IBAction func mettingTapped(_ sender: Any) {
        
        delegate.mettingTapped()
        //        mettingSelected()
        
    }
    @IBAction func sitesTapped(_ sender: Any) {
        //        sitesSelected()
        delegate.sitesTapped()
        
    }
    @IBAction func bacTestTapped(_ sender: Any) {
        //        bacTestSelected()
        delegate.bacTestTapped()
        
    }
    @IBAction func supportTapped(_ sender: Any) {
        //        supportSelected()
        delegate.supportTapped()
        
    }
    @IBAction func logoutTapped(_ sender: Any) {
        delegate.logoutTapped()
        
    }
    func changeColor(color: UIColor, iconView: UIImageView){
        iconView.image = iconView.image?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = color
    }
    @IBAction func surveyTapped(_ sender: Any) {
        delegate.surveyTapped()
    }
    func testStatusSelected(){
        changeColor(color: selectedColor, iconView: testStatusIcon)
        changeColor(color: unSelectedColor, iconView: bacTestIcon)
        changeColor(color: unSelectedColor, iconView: mettingIcon)
        changeColor(color: unSelectedColor, iconView: addressIcon)
        changeColor(color: unSelectedColor, iconView: checkInIcon)
        changeColor(color: unSelectedColor, iconView: surveyIcon)
    }
    func mettingSelected(){
        changeColor(color: unSelectedColor, iconView: testStatusIcon)
        changeColor(color: unSelectedColor, iconView: bacTestIcon)
        changeColor(color: unSelectedColor, iconView: mettingIcon)
        changeColor(color: unSelectedColor, iconView: addressIcon)
        changeColor(color: selectedColor, iconView: checkInIcon)
        changeColor(color: unSelectedColor, iconView: surveyIcon)
    }
    func sitesSelected(){
        changeColor(color: unSelectedColor, iconView: testStatusIcon)
        changeColor(color: unSelectedColor, iconView: bacTestIcon)
        changeColor(color: unSelectedColor, iconView: mettingIcon)
        changeColor(color: selectedColor, iconView: addressIcon)
        changeColor(color: unSelectedColor, iconView: checkInIcon)
        changeColor(color: unSelectedColor, iconView: surveyIcon)
    }
    func bacTestSelected(){
        changeColor(color: unSelectedColor, iconView: testStatusIcon)
        changeColor(color: selectedColor, iconView: bacTestIcon)
        changeColor(color: unSelectedColor, iconView: mettingIcon)
        changeColor(color: unSelectedColor, iconView: addressIcon)
        changeColor(color: unSelectedColor, iconView: checkInIcon)
        changeColor(color: unSelectedColor, iconView: surveyIcon)
    }
    
    func supportSelected(){
        changeColor(color: unSelectedColor, iconView: testStatusIcon)
        changeColor(color: unSelectedColor, iconView: bacTestIcon)
        changeColor(color: selectedColor, iconView: mettingIcon)
        changeColor(color: unSelectedColor, iconView: addressIcon)
        changeColor(color: unSelectedColor, iconView: checkInIcon)
        changeColor(color: unSelectedColor, iconView: surveyIcon)
    }
    func surveySelected(){
        changeColor(color: unSelectedColor, iconView: testStatusIcon)
        changeColor(color: unSelectedColor, iconView: bacTestIcon)
        changeColor(color: unSelectedColor, iconView: mettingIcon)
        changeColor(color: unSelectedColor, iconView: addressIcon)
        changeColor(color: unSelectedColor, iconView: checkInIcon)
        changeColor(color: selectedColor, iconView: surveyIcon)
        
    }
    
}

