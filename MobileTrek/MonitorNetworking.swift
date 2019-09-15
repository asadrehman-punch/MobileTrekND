//
//  MonitorNetworking.swift
//  Proof
//
//  Created by Steven Fisher on 3/20/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MonitorNetworking: NSObject {
	private var userPlatform: Platform!
	
	init(userPlatform: Platform) {
		self.userPlatform = userPlatform
	}
	
	func checkWaitTime(closure: @escaping (_ isAvailable: Bool, _ waitTime: Int?, _ message: String) -> ()) {
		Alamofire.request(userPlatform.baseUrl + "MonitoringQueueStatus", method: .get)
			.responseJSON { response in
				switch response.result {
				case .success(let value):
					let json = JSON(value)
					
					if let isAvailable = json["isAvailable"].bool,
						let message = json["message"].string {
						let minuteWait = json["minuteWait"].int
						
						closure(isAvailable, minuteWait, message)
					}
					else {
						closure(false, nil, "An unexpected error occurred while attempting to fetch wait time. Please try again in a few minutes.")
						print("json = \(json)")
					}
					
				case .failure(let error):
					closure(false, nil, "An error occurred while attempting to fetch wait time: " + error.localizedDescription)
				}
		}
	}
	
	func fetchAssignedRoom(closure: @escaping (_ roomName: String?, _ message: String) -> ()) {
		let params: [String: String] = [
			"pct": userPlatform.globalPartId
		]
		
		Alamofire.request(userPlatform.baseUrl + "MonitoringRoom", method: .get, parameters: params, encoding: URLEncoding.default)
			.responseJSON { response in
				switch response.result {
				case .success(let value):
					let json = JSON(value)
					
					if let statusCode = json["statusCode"].string,
						let message = json["message"].string {
						
						if let roomName = json["name"].string, statusCode == "200" {
							closure(roomName, message)
						}
						else if statusCode == "400" {
							closure(nil, message)
						}
						else {
							closure(nil, message)
							print("Fetching assigned room number message: \(message)")
						}
					}
					else {
						closure(nil, "failed")
						print("Fetching assigned room number failed: statusCode or message")
					}
					
				case .failure(let error):
					closure(nil, "failed")
					print("Fetching assigned room number failed: \(error.localizedDescription)")
				}
		}
	}
	
	func addUserToQueue(closure: @escaping (_ token: String?, _ status: String) -> ()) {
		let headers: [String: String]? = [
			"participant_id": userPlatform.globalPartId
		]
		
		Alamofire.request(userPlatform.baseUrl + "AssignParticipantToMonitor", method: .post, headers: headers)
			.responseJSON { response in
				switch(response.result) {
				case .success(let value):
					let jsonData = JSON(value)
					
					print("AssignParticipantToMonitor response = \(jsonData)")
					
					if let statusCode = jsonData["statusCode"].int {
						if (statusCode == 200) {
							self.fetchStreamToken({ resultToken in
								if let token = resultToken {
									closure(token, "In queue for monitor")
									// self.listenForInvites(token)
								}
								else {
									closure(nil, "Live monitoring is currently unavailable")
								}
							})
						}
						else if (statusCode == 300) {
							closure(nil, "No monitors are currently available")
						}
						else if let message = jsonData["message"].string {
							closure(nil, "Live monitoring is currently unavailable")
							print("Error found while assigning participant to monitor: " + message)
						}
					}
					
					
				case .failure(let error):
					print(error)
				}
		}
	}
	
	func removeUserFromQueue(_ closure: @escaping (_ message: String) -> ()) {
		let headers: [String: String]? = [
			"participant_id": userPlatform.globalPartId
		]
		
		Alamofire.request(userPlatform.baseUrl + "RemoveParticipantFromQueue", method: .post, headers: headers)
			.responseJSON { response in
				switch (response.result) {
				case .success(let value):
					let jsonData = JSON(value)
					
					if let statusCode = jsonData["statusCode"].int {
						if (statusCode == 200) {
							print("Successfuly removed participant from queue")
							closure("success")
						}
						else if let message = jsonData["message"].string {
							print("Error found while removing participant from queue: \(message)")
							closure("Unable to leave queue: \(message)")
						}
					}
					
				case .failure(let error):
					print(error)
					closure("Error found while removing participant from queue: \(error.localizedDescription)")
				}
				
		}
	}
	
	func fetchStreamToken(_ completionHandler: @escaping ((String?) -> (Void))) {
		let headers: [String: String]? = [
			"identity": userPlatform.globalPartId
		]
		
		Alamofire.request(userPlatform.baseUrl + "GenerateStreamToken", method: .post, headers: headers)
			.responseJSON { response in
				switch (response.result) {
				case .success(let value):
					let jsonData = JSON(value)
					
					if let statusCode = jsonData["statusCode"].int {
						if (statusCode == 200) {
							if let token = jsonData["token"].string {
								print("Successfully generated token")
								completionHandler(token)
							}
							else {
								print("Unkown error generating token")
								completionHandler(nil)
							}
						}
						else if let message = jsonData["message"].string {
							print("Error generating token: " + message)
						}
					}
					
				case .failure(let error):
					print(error)
					completionHandler(nil)
					
				}
		}
	}
}
