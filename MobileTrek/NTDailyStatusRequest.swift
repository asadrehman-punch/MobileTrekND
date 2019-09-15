//
//  NTDailyStatusRequest.swift
//  MobileTrek
//
//  Created by Steven Fisher on 2/25/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTDailyStatusRequest: NSObject {
	
	fileprivate var baseUrl: String!
	fileprivate var participantId: String!
	fileprivate var pin: String!
	fileprivate var gpsLat: String!
	fileprivate var gpsLong: String!
	
	init(baseUrl: String, participantId: String, pin: String, gpsLat: String, gpsLong: String) {
		self.baseUrl = baseUrl + "checkinstatus"
		self.participantId = participantId
		self.pin = pin
		self.gpsLat = gpsLat
		self.gpsLong = gpsLong
	}
	
    func sendRequest(_ closure: @escaping (_ message: String, _ confirmationNumber: String?, _ confirmationMessage: String?, _ programMessage: String?, _ specialMessage: String?, _ pdfJson: String?, _ barCodeImage: String?, _ questPdfString: String?) -> Void) {
		let headers: [String:String] =
		[
			"participant_id": participantId,
			"pin": pin,
			"gps_lat": gpsLat,
			"gps_long": gpsLong
		]
		
		BFLog("Prepared DailyStatusRequest with Headers = \(headers)")
		
		Alamofire.request(baseUrl, method: .post, headers: headers)
		.responseJSON { response in
			switch (response.result) {
			case .success:
				let json = JSON(response.result.value!)
				
				let prgMsg = self.safeCheckNonNullableField(strValue: json["program_message"].string)
				let specMsg = self.safeCheckNonNullableField(strValue: json["special_message"].string)
				
				if let _ = json["test_today"].bool,
					let confirmationNum = json["confirmation"].string,
					let confirmationMsg = json["confirmation_message"].string,
					let testStatusMessage = json["test_status"].string {
					let barCodeImage = json["Quest_barcode"].string
                    let questPdf = json["Quest_pdf"].string
					if let echainPdf = json["E_chain"].string {
                        if((barCodeImage != nil || barCodeImage != "") && (questPdf != nil || questPdf != "" )){
                            closure(testStatusMessage, confirmationNum, confirmationMsg, prgMsg, specMsg, echainPdf, barCodeImage, questPdf)
                        }
                        else{
                            closure(testStatusMessage, confirmationNum, confirmationMsg, prgMsg, specMsg, echainPdf, nil, nil)
                        }
					}
					else {
                        if((barCodeImage != nil || barCodeImage != "") && (questPdf != nil || questPdf != "" )){
                            closure(testStatusMessage, confirmationNum, confirmationMsg, prgMsg, specMsg, nil, barCodeImage, questPdf)
                        }else{
                            closure(testStatusMessage, confirmationNum, confirmationMsg, prgMsg, specMsg, nil, nil, nil)
                        }
						
					}
				}
				else if let testStatusMessage = json["test_status"].string {
					closure(testStatusMessage, nil, nil, prgMsg, specMsg, nil, nil, nil)
				}
				else {
					let message = "An error occurred while attempting to retrieve your testing status."
					
					closure(message, nil, nil, nil, nil, nil, nil, nil)
				}
				
				
			case .failure(let error):
				closure(error.localizedDescription, nil, nil, nil, nil, nil, nil, nil)
			}
		}
	}
	
	private func safeCheckNonNullableField(strValue: String?) -> String? {
		if strValue != nil && strValue!.isEmpty {
			return nil
		}
		
		return strValue
	}
	
}
