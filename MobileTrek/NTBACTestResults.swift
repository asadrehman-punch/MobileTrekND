//
//  NTBACTestResults.swift
//  MobileTrek
//
//  Created by Steven Fisher on 8/24/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTBACTestResults: NSObject {
	
	private var baseUrl: String!
	private var timeStamp: String!
	private var participantId: String!
	
	@objc init(baseUrl: String, timeStamp: String, participantId: String) {
		self.baseUrl = baseUrl + "BACTestResults"
		self.timeStamp = timeStamp
		self.participantId = participantId
	}
	
	@objc func sendRequest(_ closure: @escaping (_ inputTime: String?, _ nextTestTime: String?,
		_ isVideoRequired: Bool, _ message: String) -> Void) {
		let params: [String: String] = [
			"timestamp": timeStamp,
			"pct_id": participantId
		]
		
		Alamofire.request(baseUrl, parameters: params).responseJSON { response in
			switch response.result {
			case .success:
				let json = JSON(response.result.value!)
				
				closure(json["inputTime"].string,
				        json["nextTestTime"].string,
				        json["isVideoRequired"].bool ?? false,
				        json["message"].string ?? "An unknown error occurred")
				
			case .failure(let error):
				closure(nil, nil, false, "error: \(error.localizedDescription)")
			}
		}
	}
}
