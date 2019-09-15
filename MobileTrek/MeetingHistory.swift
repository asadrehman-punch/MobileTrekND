//
//  MeetingHistory.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/3/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import SwiftyJSON

class MeetingHistory: NSObject {
	var checkInDate: String?
	var checkOutDate: String?
	var meetingType: String?
	var meetingTopic: String?
	var meetingName: String?
	
	init(checkInDate: String?, checkOutDate: String?, meetingType: String?,
	     meetingTopic: String?, meetingName: String?) {
		self.checkInDate = checkInDate
		self.checkOutDate = checkOutDate
		self.meetingType = meetingType
		self.meetingTopic = meetingTopic
		self.meetingName = meetingName
	}
	
	static func parseFromJSON(_ meetingcheckinout: [JSON]) -> [MeetingHistory]? {
		if meetingcheckinout.count > 0 {
			// Meeting history is available
			var tempMeetingcheckinout = [MeetingHistory]()
			for checkins in meetingcheckinout {
				let tempCheckinout = MeetingHistory(checkInDate: checkins["checkindate"].string,
				                                    checkOutDate: checkins["checkoutdate"].string,
				                                    meetingType: checkins["meetingtype"].string,
				                                    meetingTopic: checkins["topic"].string,
				                                    meetingName: checkins["meetingname"].string)
				
				// Don't add meetings that don't have any information
				if tempCheckinout.checkInDate == nil && tempCheckinout.checkOutDate == nil
					&& tempCheckinout.meetingType == nil && tempCheckinout.meetingTopic == nil
					&& tempCheckinout.meetingName == nil {
					continue
				}
				
				tempMeetingcheckinout.append(tempCheckinout)
			}
			
			return tempMeetingcheckinout
		}
		else {
			// Meeting history not available
			return nil
		}
	}
}
