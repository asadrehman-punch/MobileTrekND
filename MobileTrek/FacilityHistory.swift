//
//  FacilityHistory.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/3/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import SwiftyJSON

class FacilityHistory: NSObject {
	var checkInDate: String?
	var checkOutDate: String?
	
	init(checkInDate: String?, checkOutDate: String?) {
		self.checkInDate = checkInDate
		self.checkOutDate = checkOutDate
	}
	
	static func parseFromJSON(_ facilitycheckinout: [JSON]) -> [FacilityHistory]? {
		if (facilitycheckinout.count > 0) {
			var tempFacilitycheckinout = [FacilityHistory]()
			for checkins in facilitycheckinout {
				let checkInDate: String? = checkins["checkindate"].string
				let checkOutDate: String? = checkins["checkoutdate"].string
				
				tempFacilitycheckinout.append(FacilityHistory(checkInDate: checkInDate, checkOutDate: checkOutDate))
			}
			
			return tempFacilitycheckinout
		}
		else {
			// Facility check in history not available
			return nil
		}
	}
}
