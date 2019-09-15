//
//  NTLoginRequest.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/9/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTLoginRequest: NSObject {
	
	var baseUrl: String!
	var participantId: String!
	var pin: String!
	
	init(baseUrl: String, participantId: String, pin: String) {
		self.baseUrl = baseUrl + "login"
		self.participantId = participantId
		self.pin = pin
	}
	
	func sendRequest(_ closure: @escaping (_ successful: Bool, _ sobrietyDate: String?, _ bacDevice: String? , _ message: String) -> Void) {
		let headers: [String:String] =
		[
			"participant_id": participantId,
			"pin": pin
		]
		
		Alamofire.request(baseUrl, method: .post, headers: headers)
		.responseJSON { response in
			switch response.result {
			case .success:
				let json = JSON(response.result.value!)
				
				if let statusCode = json["statusCode"].int, statusCode == 200 {
					if let sobriety = json["sobrietyDate"].string {
						closure(true, sobriety, json["bac_device"].string, "success")
					}
					else {
						closure(true, nil, json["bac_device"].string, "success")
					}
				}
				else if let message = json["message"].string {
					closure(false, nil, nil, message)
				}
				else {
					closure(false, nil, nil, "Unable to login")
				}
				
			case .failure(let error):
				BFLog(error.localizedDescription)
				closure(false, nil, nil, error.localizedDescription)
			}
		}
	}
	
}
