//
//  NTFeedbackRequest.swift
//  MobileTrek
//
//  Created by Steven Fisher on 11/1/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTFeedbackRequest: NSObject {
	private let url: String = "https://rtivr.secure.force.com/services/apexrest/MTrekFeedback"
	
	func sendRequest(programId: String, participantId: String, feedback: String,
	                 _ closure: @escaping (_ success: Bool, _ message: String) -> Void) {
		let headers: [String:String] = [
			"Content-Type": "application/json"
		]
		
		let params: [String:String] = [
			"programId": programId,
			"participantId": participantId,
			"feedback": feedback
		]
		
		Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
			.responseJSON { response in
			switch response.result {
			case .success:
				let json = JSON(response.result.value!)
				
				if let message = json["message"].string {
					closure(message == "success", message)
				}
				else {
					print("json = \(json)")
					closure(false, "An unknown error has occurred while trying to send feedback.")
				}
				
			case .failure(let error):
				closure(false, error.localizedDescription)
			}
		}
	}
}
