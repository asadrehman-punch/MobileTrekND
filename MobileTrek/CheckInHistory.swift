//
//  CheckInHistory.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/5/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckInHistory: NSObject {
	var date: String = ""
	var confirmationNum: String = ""
	var selectedForTesting: Bool = false
	var splitDate: String?
	var status: String?
	
	static func parseFromJSON(_ checkinstatus: [JSON]) -> [CheckInHistory]? {
		if (checkinstatus.count > 0) {
			var tempCheckinstatus = [CheckInHistory]()
			for checkins in checkinstatus {
				let tempCheckin = CheckInHistory()
				
				if let date = checkins["checkindate"].string {
					tempCheckin.date = date
					
					BFLog("Found checkin date: \(date)")
					
					// Split the string to get the date and final login status
					let comps = date.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
					
					if comps.count == 2 {
						let splitDate = comps[0].trimmingCharacters(in: .whitespacesAndNewlines)
						
						// We have two items
						tempCheckin.splitDate = splitDate
						
						var status = comps[1].trimmingCharacters(in: .whitespacesAndNewlines)
						
						if let firstChar = status.first,
							let lastChar = status.last {
							if firstChar == "(" && lastChar == ")" {
								status.removeFirst()
								status.removeLast()
							}
						}
						
						tempCheckin.status = status
					}
				}
				
				if let confirmNum = checkins["confirmationnumber"].string {
					tempCheckin.confirmationNum = confirmNum
				}
				
				if let testing = checkins["testtoday"].bool {
					tempCheckin.selectedForTesting = testing
				}
				
				tempCheckinstatus.append(tempCheckin)
			}
			
			return tempCheckinstatus
		}
		else {
			// Check in status history not available
			return nil
		}
	}
}
