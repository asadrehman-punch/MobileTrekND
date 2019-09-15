//
//  CheckInHistoryTests.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/5/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import MobileTrek

class CheckInHistoryTests: XCTestCase {
    
	func testNoHistory() {
		let checkInHistory: [JSON] = []
		
		let hist = CheckInHistory.parseFromJSON(checkInHistory)
		XCTAssertTrue(hist == nil)
	}
	
	func testDateSplit() {
		let checkInHistory: [JSON] = [
			["checkindate": "05/01/2017", "confirmationnumber": "000001", "testtoday": false],
			["checkindate": "05/02/2017 - (Web)", "confirmationnumber": "000001", "testtoday": true],
			["checkindate": "05/02/2017 - (Phone Incomplete)", "testtoday": true],
			["checkindate": "05/02/2017 - (Excused)", "testtoday": true],
			["checkindate": "05/02/2017 - (SMS - Acknowledged)", "testtoday": true]
		]
		
		if let hist = CheckInHistory.parseFromJSON(checkInHistory) {
			XCTAssertEqual(hist[0].date, "05/01/2017")
			XCTAssertEqual(hist[0].splitDate, nil)
			XCTAssertEqual(hist[0].status, nil)
			
			XCTAssertEqual(hist[1].date, "05/02/2017 - (Web)")
			XCTAssertEqual(hist[1].splitDate!, "05/02/2017")
			XCTAssertEqual(hist[1].status!, "Web")
			
			XCTAssertEqual(hist[2].date, "05/02/2017 - (Phone Incomplete)")
			XCTAssertEqual(hist[2].splitDate!, "05/02/2017")
			XCTAssertEqual(hist[2].status!, "Phone Incomplete")
			
			XCTAssertEqual(hist[3].date, "05/02/2017 - (Excused)")
			XCTAssertEqual(hist[3].splitDate!, "05/02/2017")
			XCTAssertEqual(hist[3].status!, "Excused")
			
			XCTAssertEqual(hist[4].date, "05/02/2017 - (SMS - Acknowledged)")
			XCTAssertEqual(hist[4].splitDate!, "05/02/2017")
			XCTAssertEqual(hist[4].status!, "SMS - Acknowledged")
		}
		else {
			XCTFail("Unable to get meeting history!")
		}
	}
    
}
