//
//  NTHistoryRequest.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/19/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTHistoryRequest: NSObject {

	var baseUrl = ""
	var participantId: String = ""
	var pin: String = ""
	
	init(baseUrl: String, participantId: String, pin: String) {
		self.baseUrl = baseUrl + "history"
		self.participantId = participantId
		self.pin = pin
	}
	
	func sendRequest(_ closure: @escaping (_ success: Bool, _ message: String,
		_ checkInStatusHistory: [CheckInHistory]?, _ facilityCheckinoutHistory: [FacilityHistory]?,
		_ meetingCheckinoutHistory: [MeetingHistory]?, _ bacTestHistory: [BacTestHistory]?) -> Void) {
		
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
					
					if let checkinstatus = json["checkinstatus"].array,
						let facilitycheckinout = json["facilitycheckinout"].array,
						let meetingcheckinout = json["meetingcheckinout"].array,
						let bactest = json["bactests"].array {
						
						let retCheckinstatus = CheckInHistory.parseFromJSON(checkinstatus)
						let retFacilitycheckinout = FacilityHistory.parseFromJSON(facilitycheckinout)
						let retMeetingcheckinout = MeetingHistory.parseFromJSON(meetingcheckinout)
						let retBactest = BacTestHistory.parseFromJSON(bactest)
						
						closure(true, "Success", retCheckinstatus, retFacilitycheckinout, retMeetingcheckinout, retBactest)
					}
					else if let message = json["success"].string {
						closure(false, message, nil, nil, nil, nil)
					}
					else {
						closure(false, "An unknown error has occurred while fetching history.", nil, nil, nil, nil)
					}
					
				case .failure(let error):
					closure(false, error.localizedDescription, nil, nil, nil, nil)
				}
		}
	}
}
