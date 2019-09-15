//
//  Graphics.swift
//  MobileTrek
//
//  Created by Steven Fisher on 10/28/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit

public class Graphics: NSObject {
	
	@objc static let primaryColor = UIColor(red: 0.137, green: 0.141, blue: 0.294, alpha: 1.0)
	@objc static let backgroundColor = UIColor(red: 0.935, green: 0.922, blue: 0.945, alpha: 1.0)
	@objc static let lightAccentColor = UIColor(red: 0.894, green: 0.875, blue: 0.914, alpha: 1.0)
	@objc static let darkAccentColor = UIColor(red: 0.855, green: 0.831, blue: 0.882, alpha: 1.0)
	@objc static let progressColor = UIColor(red: 0.686, green: 0.725, blue: 0.247, alpha: 1.0)
	
	static func addBorder(view: UIView, position: BorderPosition, color: UIColor = UIColor.lightGray) {
		let borderView = UIView()
		borderView.backgroundColor = color
		borderView.alpha = 0.2
		borderView.tag = 200
		
		view.addSubview(borderView)
		
		borderView.translatesAutoresizingMaskIntoConstraints = false
		
		switch position {
		case .top:
			view.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "H:|-0-[border]-0-|", options: [], metrics: nil, views: ["border": borderView]))
			view.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "V:|-0-[border(1)]", options: [], metrics: nil, views: ["border": borderView]))
			
		case .bottom:
			view.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "H:|-0-[border]-0-|", options: [], metrics: nil, views: ["border": borderView]))
			view.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "V:[border(1)]-0-|", options: [], metrics: nil, views: ["border": borderView]))
			
		case .left:
			view.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "H:|-0-[border(1)]", options: [], metrics: nil, views: ["border": borderView]))
			view.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "V:|-0-[border]-0-|", options: [], metrics: nil, views: ["border": borderView]))
			
		case .right:
			view.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "H:[border(1)]-0-|", options: [], metrics: nil, views: ["border": borderView]))
			view.addConstraints(NSLayoutConstraint.constraints(
				withVisualFormat: "V:|-0-[border]-0-|", options: [], metrics: nil, views: ["border": borderView]))
		}
	}
	
	@objc static func addRoundedCorners(view: UIView, corners: UIRectCorner, radius: Double) {
		let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let maskLayer = CAShapeLayer()
		maskLayer.frame = view.bounds
		maskLayer.path = maskPath.cgPath
		view.layer.mask = maskLayer
	}
	
	@objc static func scaleImage(_ image: UIImage, newSize: CGSize) -> UIImage {
		UIGraphicsBeginImageContext(newSize)
		image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
	
	enum BorderPosition {
		case top
		case right
		case bottom
		case left
	}
}
