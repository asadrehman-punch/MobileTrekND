//
//  NTOptpermsRequest.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/13/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTOptpermsRequest: NSObject {

	var baseUrl: String!
	var participantId: String!
	
	struct RTOptions {
		/*Button Options*/
		var support: Bool = false
		var nearestCollectionLocations: Bool = false
		var alcoholBACTest: Bool = false
		var checkDailyStatus: Bool = false
        var survey: Bool = false
		
		/* BAC Options */
		var showBracLevel: Bool = false
		var showBracResult: Bool = false
		var requireBACConfirmation: Bool = false
        var breathalyzerId: String? = nil
        var bacRecognition: Bool = false
		
		/* CheckIn/Out Options */
		var collectionSiteCheckIn: Bool = false
		var collectionSiteCheckOut: Bool = false
		var collectionSiteCheckInLocation: Bool = false
		var collectionSiteCheckOutLocation: Bool = false
		var collectionSiteCheckInSelfie: Bool = false
		var collectionSiteCheckOutSelfie: Bool = false
		var meetingCheckIn: Bool = false
		var meetingCheckOut: Bool = false
		var meetingCheckInName: Bool = false
		var meetingCheckInLocation: Bool = false
		var meetingCheckOutLocation: Bool = false
		var meetingCheckInSelfie: Bool = false
		var meetingCheckOutSelfie: Bool = false
        var meetingCheckInAttendance: Bool = false
        var meetingCheckInSignature: Bool = false
		var meetingAttendance: Bool = false
		var meetingSignature: Bool = false
        var cocLogData: Bool = false
        var cocNumber: Bool = false
        var cocOptionNumber: Bool = false
        var cocObserved: Bool = false
        var cocNumberCheckOut: Bool = false
        var cocOptionNumberCheckOut: Bool = false
        var cocObservedCheckOut: Bool = false
        var cocFormCheckIn: Bool = false
        var cocFormCheckOut: Bool = false
        var questAuthorization: Bool = false
		var sobrietyDate: Bool = false
		var checkInHistory: Bool = false
		var facilityCheckInHistory: Bool = false
		var meetingCheckInHistory: Bool = false
		var bacTestHistory: Bool = false
		var topic: Bool = false
       
		var monitoring: Bool = false
	}
	
	init(baseUrl: String, participantId: String) {
		self.baseUrl = baseUrl + "optperms"
		self.participantId = participantId
	}
	
	func sendRequest(_ closure: @escaping (_ successful: Bool, _ message: String, _ options: RTOptions) -> Void) {
		let headers: [String:String] =
		[
			"participant_id": participantId
		]
		
		Alamofire.request(baseUrl, method: .post, headers: headers)
		.responseJSON { response in
			switch response.result {
			case .success:
				let json = JSON(response.result.value!)
				
				if let isError = json["Error"].bool , isError {
					closure(false, "An error occurred while attempting to retrieve options.", RTOptions())
				}
				
				var options = RTOptions()
				/*Button Options*/
                if let survey = json["data"]["survey"].bool { options.survey = survey }
				if let support = json["data"]["support"].bool { options.support = support }
				if let colLocs = json["data"]["nearest_collection_locations"].bool { options.nearestCollectionLocations = colLocs }
				if let bacTest = json["data"]["alcohol_bac_test"].bool { options.alcoholBACTest = bacTest }
				if let testStatus = json["data"]["check_daily_test_status"].bool { options.checkDailyStatus = testStatus }
				
				/* BAC Options */
				if let showBracLevel = json["data"]["show_brac_level"].bool { options.showBracLevel = showBracLevel }
				if let showBracResult = json["data"]["show_brac_result"].bool { options.showBracResult = showBracResult }
                
                options.breathalyzerId = json["breathalyzer_id"].string
				
				/* Collection Site CheckIn/Out Options */
				if let colCheckIn = json["data"]["check_in_at_collection_site"].bool { options.collectionSiteCheckIn = colCheckIn }
				if let colCheckOut = json["data"]["check_out_at_collection_site"].bool { options.collectionSiteCheckOut = colCheckOut }
				if let colCheckInLoc = json["data"]["check_in_location_at_collection_site"].bool { options.collectionSiteCheckInLocation = colCheckInLoc }
				if let colCheckOutLoc = json["data"]["check_out_location_at_collection_site"].bool { options.collectionSiteCheckOutLocation = colCheckOutLoc }
				if let colCheckInSelfie = json["data"]["check_in_selfie_at_collection_site"].bool { options.collectionSiteCheckInSelfie = colCheckInSelfie }
				if let colCheckOutSelfie = json["data"]["check_out_selfie_at_collection_site"].bool { options.collectionSiteCheckOutSelfie = colCheckOutSelfie }
                if let cocLogData = json["data"]["coc_log_data"].bool { options.cocLogData = cocLogData }
                if let cocObserved = json["data"]["coc_observed"].bool { options.cocObserved = cocObserved }
                if let cocOptionNumber = json["data"]["coc_option_number"].bool { options.cocOptionNumber = cocOptionNumber }
                if let cocNumber = json["data"]["coc_number"].bool { options.cocNumber = cocNumber }
                if let cocFormCheckIn = json["data"]["coc_form_check_in"].bool { options.cocFormCheckIn = cocFormCheckIn }
                if let cocFormCheckOut = json["data"]["coc_form_check_out"].bool { options.cocFormCheckOut = cocFormCheckOut }
				if let questAuthorization = json["data"]["lab_authorization_form"].bool { options.questAuthorization = questAuthorization }
				/* Meeting CheckIn/Out Options */
				if let metCheckIn = json["data"]["meeting_check_in"].bool { options.meetingCheckIn = metCheckIn }
				if let metCheckOut = json["data"]["meeting_check_out"].bool { options.meetingCheckOut = metCheckOut }
				if let metCheckInName = json["data"]["meeting_check_in_name"].bool { options.meetingCheckInName = metCheckInName }
				if let metCheckInLoc = json["data"]["meeting_check_in_location"].bool { options.meetingCheckInLocation = metCheckInLoc }
				if let metCheckOutLoc = json["data"]["meeting_check_out_location"].bool { options.meetingCheckOutLocation = metCheckOutLoc }
				if let metCheckInSelfie = json["data"]["meeting_check_in_selfie"].bool { options.meetingCheckInSelfie = metCheckInSelfie }
				if let metCheckOutSelfie = json["data"]["meeting_check_out_selfie"].bool { options.meetingCheckOutSelfie = metCheckOutSelfie }
                if let metCheckInAttendance = json["data"]["meeting_check_in_attendance"].bool { options.meetingCheckInAttendance = metCheckInAttendance }
                if let metCheckInSig = json["data"]["meeting_check_in_signature"].bool { options.meetingCheckInSignature = metCheckInSig }
				if let metAttendance = json["data"]["meeting_attendance"].bool { options.meetingAttendance = metAttendance }
				if let metSignature = json["data"]["meeting_signature"].bool { options.meetingSignature = metSignature }
				
				if let sobrietyDate = json["data"]["sobriety_date"].bool { options.sobrietyDate = sobrietyDate }
				if let checkInHistory = json["data"]["checkin_history"].bool { options.checkInHistory = checkInHistory }
				if let facilityCheckInHistory = json["data"]["collection_site_checkin_checkout_history"].bool { options.facilityCheckInHistory = facilityCheckInHistory }
				if let meetingCheckInHistory = json["data"]["meeting_checkin_checkout_history"].bool { options.meetingCheckInHistory = meetingCheckInHistory }
				if let bacTestHistory = json["data"]["bac_test_history"].bool { options.bacTestHistory = bacTestHistory }
				if let topic = json["data"]["topic"].bool { options.topic = topic }
				
				if let monitoring = json["data"]["monitoring"].bool { options.monitoring = monitoring }
				if let requireBACConfirmation = json["data"]["require_bac_confirmation"].bool { options.requireBACConfirmation = requireBACConfirmation }
                if let bacRecognition = json["data"]["bac_recognition"].bool { options.bacRecognition = bacRecognition }
                if let cocNumberCheckout = json["data"]["coc_number_check_out"].bool { options.cocNumberCheckOut = cocNumberCheckout }
                if let cocObservedCheckout = json["data"]["coc_observed_check_out"].bool {options.cocObservedCheckOut = cocObservedCheckout}
                if let cocOptionNumberCheckout = json["data"]["coc_option_number_check_out"].bool {options.cocOptionNumberCheckOut = cocOptionNumberCheckout}
                
				closure(true, "success", options)
				
			case .failure(let error):
				closure(false, error.localizedDescription, RTOptions())
			}
		}
	}
	
}









