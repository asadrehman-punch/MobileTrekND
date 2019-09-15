//
//  FacilityHistoryModelTests.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/5/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import MobileTrek

class FacilityHistoryModelTests: XCTestCase {
	
	func testNoHistory() {
		let facilityHistory: [JSON] = []
		
		let hist = FacilityHistory.parseFromJSON(facilityHistory)
		XCTAssertTrue(hist == nil)
	}
	
	func testCheckInDateNil() {
		let facilityHistory: [JSON] = [
			["checkoutdate": "02/01/2017 4:31 PM"]
		]
		
		if let hist = FacilityHistory.parseFromJSON(facilityHistory) {
			XCTAssertEqual(hist[0].checkInDate, nil)
			XCTAssertEqual(hist[0].checkOutDate, "02/01/2017 4:31 PM")
		}
		else {
			XCTFail("Unable to get facility history!")
		}
	}
	
	func testCheckOutDateNil() {
		let facilityHistory: [JSON] = [
			["checkindate": "02/01/2017 4:31 PM"]
		]
		
		if let hist = FacilityHistory.parseFromJSON(facilityHistory) {
			XCTAssertEqual(hist[0].checkInDate, "02/01/2017 4:31 PM")
			XCTAssertEqual(hist[0].checkOutDate, nil)
		}
		else {
			XCTFail("Unable to get facility history!")
		}
	}
    
}
