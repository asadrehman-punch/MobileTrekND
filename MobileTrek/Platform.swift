//
//  Platform.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/19/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class Platform: NSObject {
	
	private static var privateShared: Platform?
	
	@objc var globalPartId: String = ""
	@objc var globalPin: String = ""
	@objc var globalProgramId: String = ""
	@objc var baseUrl: String = ""
	@objc var globalLat: String = ""
	@objc var globalLng: String = ""
	@objc var checkinorout: String = ""
	@objc var checkInType: String = ""
	@objc var meetingType: String = ""
	@objc var sobrietyDate: String? = nil
	@objc var meetingTypes: [String]? = nil
	@objc var meetingTopic: String = ""
	@objc var checkInStatusHistory: [CheckInHistory]? = nil
    @objc var checkOutStatusHistory: [FacilityHistory]? = nil
    @objc var meetingHistory: [MeetingHistory]? = nil
	@objc var bacTestHistory: [BacTestHistory]? = nil
    @objc var cocNumberText: String = ""
    @objc var cocOptionNumberText: String = ""
    @objc var cocObservedText: Bool = false
    
    @objc var cocNumberCheckoutText: String = ""
    @objc var cocOptionNumberCheckoutText: String = ""
    @objc var cocObservedCheckoutText: Bool = false
    
	@objc var support: Bool = false
	@objc var nearestCollectionLocations: Bool = false
	@objc var alcoholBACTest: Bool = false
	@objc var checkDailyStatus: Bool = false
	@objc var showBracLevel: Bool = false
	@objc var showBracResult: Bool = false
	@objc var requireBACConfirmation: Bool = false
	@objc var collectionSiteCheckIn: Bool = false
	@objc var collectionSiteCheckOut: Bool = false
	@objc var collectionSiteCheckInLocation: Bool = false
	@objc var collectionSiteCheckOutLocation: Bool = false
	@objc var collectionSiteCheckInSelfie: Bool = false
	@objc var collectionSiteCheckOutSelfie: Bool = false
    @objc var cocLogData: Bool = false
    @objc var cocNumber: Bool = false
    @objc var cocOptionNumber: Bool = false
    @objc var cocObserved: Bool = false
    @objc var cocFormCheckIn: Bool = false
    @objc var cocFormCheckOut: Bool = false
    @objc var cocNumberCheckOut: Bool = false
    @objc var cocOptionNumberCheckOut: Bool = false
    @objc var cocObservedCheckOut: Bool = false

    @objc var questAuthorization: Bool = false
	@objc var meetingCheckIn: Bool = false
	@objc var meetingCheckOut: Bool = false
	@objc var meetingCheckInName: Bool = false
	@objc var meetingCheckInLocation: Bool = false
	@objc var meetingCheckOutLocation: Bool = false
	@objc var meetingCheckInSelfie: Bool = false
	@objc var meetingCheckOutSelfie: Bool = false
    @objc var meetingCheckInAttendance: Bool = false
    @objc var meetingCheckInSignature: Bool = false
	@objc var meetingAttendance: Bool = false
	@objc var meetingSignature: Bool = false
	@objc var bacDevice: String = "BACtrack"
    @objc var bacRecognition: Bool = false
	
	@objc var globalSobrietyDate: Bool = false
	@objc var globalCheckInHistory: Bool = false
	@objc var globalFacilityCheckInHistory: Bool = false
	@objc var globalMeetingCheckInHistory: Bool = false
	@objc var globalBacTestHistory: Bool = false
	@objc var globalTopic: Bool = false
	
	@objc var monitoring: Bool = false
	@objc var isInQueue: Bool = false
    
    @objc var survey: Bool = false
	
	@objc class func destroy() {
		privateShared = nil
	}
	
	@objc class func shared() -> Platform {
		guard let uwShared = privateShared else {
			privateShared = Platform()
			return privateShared!
		}
		return uwShared
	}
}
