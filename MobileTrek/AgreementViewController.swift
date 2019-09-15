//
//  AgreementViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 7/14/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class AgreementViewController: UIViewController {

	@IBOutlet weak var agreeBtn: UIButton!
	@IBOutlet weak var contBtn: UIButton!
	@IBOutlet weak var blankView: UIView!
	@IBOutlet weak var agreeLabel: ButtonBindingLabel!
	@IBOutlet weak var blankViewBottomConstraint: NSLayoutConstraint!
	
	private var didInit: Bool = false
	
	var isStoppingBy: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		initializeLayout()
	}
	
	@IBAction func agreeBtnToggle(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
	}
	
	@IBAction func continueBtn(_ sender: UIButton) {
		if agreeBtn.isSelected {
			let formatter = DateFormatter()
			formatter.dateFormat = "MM/dd/yyyy hh:mm a"
			let timeStamp = formatter.string(from: Date())
			
			let defaults = UserDefaults.standard
			defaults.set(true, forKey: "hasAgreed")
			defaults.set(timeStamp, forKey: "agreementTimestamp")
			defaults.synchronize()
			
			let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController")
			self.navigationController?.pushViewController(loginVC!, animated: true)
		}
	}

	private func initializeLayout() {
		self.view.backgroundColor = UIColor.white
		self.navigationController?.navigationBar.barTintColor = Graphics.primaryColor
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		
		blankView.backgroundColor = UIColor.white
		contBtn.backgroundColor = Graphics.primaryColor
		
		agreeBtn.setImage(UIImage(named: "buttonOn"), for: .selected)
		agreeBtn.setImage(UIImage(named: "buttonOff"), for: UIControl.State())
		
		agreeLabel.bindingButton = agreeBtn
		
		if isStoppingBy {
			agreeBtn.isHidden = true
			blankView.isHidden = true
			contBtn.isHidden = true
			
			blankViewBottomConstraint.constant = -99
		}
		
		self.navigationController?.navigationBar.tintColor = UIColor.white
	}
}
