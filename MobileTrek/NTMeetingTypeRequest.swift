//
//  NTMeetingTypeRequest.swift
//  MobileTrek
//
//  Created by Steven Fisher on 3/9/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTMeetingTypeRequest: NSObject {

    fileprivate let extUrl = "meetingactivities"
    
    fileprivate var url: String!
    fileprivate var participantId: String!
    fileprivate var pin: String!
    
    init(baseUrl: String, participantId: String, pin: String) {
        self.url = baseUrl + extUrl
        self.participantId = participantId
        self.pin = pin
    }
    
    func sendRequest(_ closure: @escaping (_ meetingActivities: [String]?, _ message: String) -> Void) {
        let headers: [String:String] =
        [
            "participant_id": participantId,
            "pin": pin
        ]
        
		Alamofire.request(url, method: .post, headers: headers)
			.responseJSON { response in
            switch (response.result) {
            case .success:
                if let retJson = response.result.value {
                    let json = JSON(retJson)
                    
                    if let activities = json["meetingactivities"].arrayObject as? [String] {
                        BFLog("Found meeting activities successfully")
                        
                        closure(activities, "success")
                    }
                    else if let _ = json["statusCode"].int {
                        BFLog("Meeting activities is NULL")
                        
                        if let message = json["message"].string {
                            closure(nil, message)
                        }
                        else {
                            closure(nil, "An error ocurred while trying to retrieve meeting activities")
                        }
                    }
                    else {
                        closure(nil, "Unable to contact MobileTrek server Error: 103")
                    }
                }
                else {
                    closure(nil, "Unable to contact MobileTrek server Error: 104")
                }
                
			case .failure(let error):
                BFLog("Error found: \(error.localizedDescription)")
                
                closure(nil, error.localizedDescription)
            }
        }
    }
    
}
