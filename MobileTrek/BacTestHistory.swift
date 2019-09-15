//
//  BacTestHistory.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/5/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import SwiftyJSON

class BacTestHistory: NSObject {
	var submittedDate: String = ""
	var importedDate: String = ""
	var bracLevel: String?
	var bracResult: String?
	
	static func parseFromJSON(_ bactests: [JSON]) -> [BacTestHistory]? {
		if (bactests.count > 0) {
			var tempBactests = [BacTestHistory]()
			for bacTest in bactests {
				let tempBacTest = BacTestHistory()
				
				if let submittedDate = bacTest["submitteddate"].string {
					tempBacTest.submittedDate = submittedDate
				}
				
				if let importedDate = bacTest["importeddate"].string {
					tempBacTest.importedDate = importedDate
				}
				
				tempBacTest.bracLevel = bacTest["bracLevel"].string
				tempBacTest.bracResult = bacTest["bracresult"].string
				
				tempBactests.append(tempBacTest)
			}
			
			return tempBactests
		}
		else {
			return nil
		}
	}
}
