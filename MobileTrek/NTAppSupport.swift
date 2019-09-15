//
//  NTAppSupport.swift
//  MobileTrek
//
//  Created by Steven Fisher on 9/5/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTAppSupport: NSObject {
	private let url: String = "https://rtivr.secure.force.com/services/apexrest/MobileAppSupport"
	private let accessKey: String = "MAAK201700003"
	
	func sendRequest(_ closure: @escaping (_ latestVersion: String?) -> Void) {
		let params: [String: String] = [
			"Access-Key": accessKey
		]
		
		Alamofire.request(url, parameters: params).responseJSON { response in
			switch response.result {
			case .success:
				let json = JSON(response.result.value!)
				
				closure(json["latestVersionSupported"].string)
				
			case .failure:
				closure(nil)
			}
		}
	}
}
