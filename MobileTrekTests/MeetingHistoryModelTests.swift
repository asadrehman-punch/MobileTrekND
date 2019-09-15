//
//  MeetingHistoryModelTests.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/5/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import MobileTrek

class MeetingHistoryModelTests: XCTestCase {
	
	func testNoHistory() {
		let meetingHistory: [JSON] = []
		
		let hist = MeetingHistory.parseFromJSON(meetingHistory)
		XCTAssertTrue(hist == nil)
	}
	
	func testCheckInDateNil() {
		let meetingHistory: [JSON] = [
			["checkoutdate": "02/01/2017"]
		]
		
		if let hist = MeetingHistory.parseFromJSON(meetingHistory) {
			XCTAssertEqual(hist[0].checkOutDate, "02/01/2017")
			XCTAssertEqual(hist[0].checkInDate, nil)
		}
		else {
			XCTFail("Unable to get meeting history!")
		}
	}
	
	func testCheckOutDateNil() {
		let meetingHistory: [JSON] = [
			["checkindate": "02/01/2017"]
		]
		
		if let hist = MeetingHistory.parseFromJSON(meetingHistory) {
			XCTAssertEqual(hist[0].checkOutDate, nil)
			XCTAssertEqual(hist[0].checkInDate, "02/01/2017")
		}
		else {
			XCTFail("Unable to get meeting history!")
		}
	}
	
	func testRegularMeetings() {
		let meetingHistory: [JSON] = [
			["checkindate": "02/01/2017", "checkoutdate": "02/01/2017"],
			["checkindate": "02/05/2017", "checkoutdate": "02/05/2017"],
			["checkindate": "02/07/2017", "checkoutdate": "02/07/2017"]
		]
		
		if let hist = MeetingHistory.parseFromJSON(meetingHistory) {
			XCTAssertEqual(hist[0].checkOutDate, "02/01/2017")
			XCTAssertEqual(hist[0].checkInDate, "02/01/2017")
			
			XCTAssertEqual(hist[1].checkOutDate, "02/05/2017")
			XCTAssertEqual(hist[1].checkInDate, "02/05/2017")
			
			XCTAssertEqual(hist[2].checkOutDate, "02/07/2017")
			XCTAssertEqual(hist[2].checkInDate, "02/07/2017")
		}
		else {
			XCTFail("Unable to get meeting history!")
		}
	}
	
	func testFormMeetings() {
		let meetingHistory: [JSON] = [
			["checkindate": "02/01/2017", "checkoutdate": "02/01/2017", "meetingtype": "AA", "topic": "test topic 1", "meetingname": "AA"],
			[],
			["checkindate": "02/07/2017", "checkoutdate": "02/07/2017", "meetingtype": "AA", "meetingname": "AA"]
		]
		
		if let hist = MeetingHistory.parseFromJSON(meetingHistory) {
			XCTAssertEqual(hist[0].checkOutDate, "02/01/2017")
			XCTAssertEqual(hist[0].checkInDate, "02/01/2017")
			
			XCTAssertEqual(hist[1].checkOutDate, "02/07/2017")
			XCTAssertEqual(hist[1].checkInDate, "02/07/2017")
		}
		else {
			XCTFail("Unable to get meeting history!")
		}
	}
	
}
