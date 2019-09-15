//
//  NTCheckInOutRequest.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/17/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTCheckInOutRequest: NSObject {

	@objc var baseUrl: String = ""
	@objc var participantId: String = ""
	@objc var pin: String = ""
	@objc var checkInType: String = ""
	@objc var action: String = ""
	@objc var gpsLat: String = ""
	@objc var gpsLong: String = ""
	@objc var meetingType: String = ""
	
	@objc var selfie: String = ""
	@objc var attendance: String = ""
	@objc var signature: String = ""
    @objc var form: String = ""
    
	@objc init(baseUrl: String, participantId: String, pin: String, checkInType: String,
	     action: String, gpsLat: String, gpsLong: String, meetingType: String) {
		self.baseUrl = baseUrl + checkInType
		self.participantId = participantId
		self.pin = pin
		self.checkInType = checkInType
		self.action = action
		self.gpsLat = gpsLat
		self.gpsLong = gpsLong
		self.meetingType = meetingType
	}
	
	@objc func sendRequest(_ closure: @escaping (_ message: String) -> Void) {
		var request = URLRequest(url: URL(string: baseUrl)!)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue(participantId, forHTTPHeaderField: "participant_id")
		request.addValue(pin, forHTTPHeaderField: "pin")
        if checkInType == "facilitycheckincheckout" && action == "checkin" {
            request.addValue("facility_c", forHTTPHeaderField: "action")
        }else{
            request.addValue(action, forHTTPHeaderField: "action")
        }
		
		request.addValue(gpsLat, forHTTPHeaderField: "gps_lat")
		request.addValue(gpsLong, forHTTPHeaderField: "gps_long")
		request.addValue(String(Int(Date().timeIntervalSince1970)), forHTTPHeaderField: "inputdate")
		
		let currentUser = Platform.shared()
		
		if checkInType == "meetingcheckincheckout" {
			request.addValue(meetingType, forHTTPHeaderField: "meetingtype")
			request.addValue(currentUser.meetingTopic, forHTTPHeaderField: "topic")
			
			let defaults = UserDefaults.standard
			
			if let meetingName = defaults.string(forKey: "STORED_MEETING_NAME") {
				if currentUser.meetingCheckInName {
					request.addValue(meetingName, forHTTPHeaderField: "meetingname")
				}
			}
        } else if checkInType == "facilitycheckincheckout"{
            //if((currentUser.cocFormCheckIn && action=="checkin") || (currentUser.cocFormCheckOut && action=="checkout")){
            
            if (action == "checkin"){
                if currentUser.collectionSiteCheckInLocation{
                    request.addValue(gpsLat, forHTTPHeaderField: "gps_lat")
                    request.addValue(gpsLong, forHTTPHeaderField: "gps_long")
                }
                if currentUser.cocNumber{
                    request.addValue(currentUser.cocNumberText, forHTTPHeaderField: "coc_number")
                }
                if currentUser.cocOptionNumber{
                    request.addValue(currentUser.cocOptionNumberText, forHTTPHeaderField: "coc_opt_num")
                }
                if(currentUser.cocObserved){
                    request.addValue(currentUser.cocObservedText ? "YES" : "NO", forHTTPHeaderField: "coc_observed")
                }
            }else if(action == "checkout"){
                if currentUser.collectionSiteCheckOutLocation{
                    request.addValue(gpsLat, forHTTPHeaderField: "gps_lat")
                    request.addValue(gpsLong, forHTTPHeaderField: "gps_long")
                }
                if currentUser.cocNumberCheckOut{
                    request.addValue(currentUser.cocNumberCheckoutText, forHTTPHeaderField: "coc_number_check_out")
                }
                if currentUser.cocOptionNumberCheckOut{
                    request.addValue(currentUser.cocOptionNumberCheckoutText, forHTTPHeaderField: "coc_opt_num_check_out")
                }
                if(currentUser.cocObservedCheckOut){
                    request.addValue(currentUser.cocObservedCheckoutText ? "YES" : "NO", forHTTPHeaderField: "coc_observed_check_out")
                }
                
            }
            //}
        }
        var encodedStr = ""
        if(checkInType == "facilitycheckincheckout"){
             encodedStr = "{ \"All_Images\":\"<Images><Picture>\(selfie)</Picture><Attendance>\(form)</Attendance><Esignature>\(signature)</Esignature></Images>\"}"
        }else{
             encodedStr = "{ \"All_Images\":\"<Images><Picture>\(selfie)</Picture><Attendance>\(attendance)</Attendance><Esignature>\(signature)</Esignature></Images>\"}"
        }
		BFLog("BaseUrl = \(baseUrl)")
		BFLog("ParticipantId = \(participantId)")
		BFLog("Pin = \(pin)")
		BFLog("Checkintype = \(checkInType)")
		BFLog("action \(action)")
		BFLog("gpsLat = \(gpsLat)")
		BFLog("gpsLong = \(gpsLong)")
		BFLog("meetingType = \(meetingType)")
		BFLog("inputdate = \(String(Int(Date().timeIntervalSince1970)))")
		
		let data = encodedStr.data(using: String.Encoding.utf8)!
		request.httpBody = data
		
		Alamofire.request(request)
			.responseString { response in
			switch response.result {
			case .success:
				if let resultStr = response.result.value {
					// Remove the quotes surrounding the string
					let removeFirst = String(resultStr.dropFirst())
					let fixedStr = String(removeFirst.dropLast())
					
					closure(fixedStr)
				}
				else {
					closure("An unknown error has ocurred")
				}
				
			case .failure(let error):
				closure("Error: \(error.localizedDescription)")
			}
		}
	}
	
}
