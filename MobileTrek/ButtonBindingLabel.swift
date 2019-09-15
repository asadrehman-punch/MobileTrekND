//
//  ButtonBindingLabel.swift
//  BadgerTrek
//
//  Created by Steven Fisher on 2/15/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class ButtonBindingLabel: UILabel {
	
	@objc var bindingButton: UIButton?
	fileprivate var bindingRecognizer: UITapGestureRecognizer!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		createBinding()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		createBinding()
	}
	
	@objc func boundLabel_Clicked(_ sender: UILabel) {
		if let button = bindingButton {
			button.sendActions(for: .touchUpInside)
		}
	}
	
	fileprivate func createBinding() {
		bindingRecognizer = UITapGestureRecognizer(target: self, action: #selector(boundLabel_Clicked))
		bindingRecognizer.numberOfTapsRequired = 1
		
		self.isUserInteractionEnabled = true
		self.addGestureRecognizer(bindingRecognizer!)
	}
	
}
