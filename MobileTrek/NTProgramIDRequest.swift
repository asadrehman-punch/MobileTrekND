//
//  NTProgramIDRequest.swift
//  MobileTrek
//
//  Created by Steven Fisher on 3/9/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTProgramIDRequest: NSObject {
    
	var programId: String = ""
	
	func sendRequest(_ closure: @escaping (_ programUrl: String?, _ message: String) -> Void) {
		let headers: [String:String] =
		[
			"program_id": programId
		]
		
		Alamofire.request("https://rtivr.secure.force.com/services/apexrest/programid", method: .post, headers: headers)
			.responseJSON { response in
				switch response.result {
				case .success:
					let json = JSON(response.result.value!)
					
					if let programUrl = json["program_url"].string {
						closure(programUrl, "success")
					}
					else if let message = json["message"].string {
						closure(nil, message)
					}
					else {
						closure(nil, "Unable to find programUrl")
					}
					
				case .failure(let error):
					closure(nil, error.localizedDescription)
				}
		}
	}
    
}
