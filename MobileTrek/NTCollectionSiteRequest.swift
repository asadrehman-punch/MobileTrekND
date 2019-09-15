//
//  NTCollectionSiteRequest.swift
//  MobileTrek
//
//  Created by Steven Fisher on 7/14/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTCollectionSiteRequest: NSObject {

	fileprivate var baseUrl: String!
	fileprivate var zipCode: String?
	fileprivate var gpsLat: String?
	fileprivate var gpsLng: String?
	fileprivate var distance: String?
	
	fileprivate var headers: [String:String]!
	
	init(baseUrl: String, zipCode: String) {
		self.baseUrl = baseUrl + "collectionsites"
		self.zipCode = zipCode
		
		headers = [
			"zip_code": self.zipCode!
		]
	}
	
	init(baseUrl: String, gpsLat: String, gpsLng: String, distance: String) {
		self.baseUrl = baseUrl + "collectionsites"
		self.gpsLat = gpsLat
		self.gpsLng = gpsLng
		self.distance = distance
		
		headers = [
			"gps_lat": self.gpsLat!,
			"gps_long": self.gpsLng!,
			"distance": self.distance!
		]
	}
	
	func sendRequest(_ closure: @escaping (_ message: String, _ collectionSites: [RTLocations]?) -> Void) {
		Alamofire.request(baseUrl, method: .post, headers: headers)
		.responseJSON { response in
			switch response.result {
			case .success:
				let json = JSON(response.result.value!)
				
				if let msg = json[0]["Message"].string {
					closure(msg, nil)
				}
				else {
					var locations = [RTLocations]()
					
					for i in 0...json.count - 1 {
						let bufferLocation = RTLocations()
						
						if let name = json[i]["Name"].string {
							bufferLocation.name = name.localizedCapitalized
						}
						
						if let address1 = json[i]["Address1"].string {
							bufferLocation.address1 = address1.localizedCapitalized
						}
						
						if let address2 = json[i]["Address2"].string { bufferLocation.address2 = address2 }
						
						if let city = json[i]["City"].string {
							bufferLocation.city = city.localizedCapitalized
						}
						
						if let state = json[i]["State"].string { bufferLocation.state = state }
						if let zip = json[i]["Zip"].string { bufferLocation.zip = zip }
						if let message = json[i]["Zip"].string { bufferLocation.message = message }
						if let distance = json[i]["Distance"].double { bufferLocation.distance = distance }
						if let phone = json[i]["Phone"].string {
							var saPhone = phone.components(separatedBy: ";")
							
							for i in 0...saPhone.count - 1 {
								saPhone[i] = saPhone[i].replacingOccurrences(of: "-", with: "")
								saPhone[i] = saPhone[i].replacingOccurrences(of: ")", with: "")
								saPhone[i] = saPhone[i].replacingOccurrences(of: "(", with: "")
								saPhone[i] = saPhone[i].replacingOccurrences(of: " ", with: "")
							}
							
							bufferLocation.phones = saPhone
							
							BFLog("Adjusted phone numbers = \(bufferLocation.phones)")
						}
						locations.append(bufferLocation)
					}
					
					closure("success", locations)
				}
				
			case .failure(let error):
				closure(error.localizedDescription, nil)
			}
		}
	}
	
}
