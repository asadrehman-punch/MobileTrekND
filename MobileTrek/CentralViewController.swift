//
//  CentralViewController.swift
//  BTrekStream
//
//  Created by Steven Fisher on 12/14/15.
//  Copyright © 2015 recoverytrek. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import TwilioVideo

class CentralViewController: UIViewController {
	
	@IBOutlet weak var queueStatusLabel: UILabel!
	@IBOutlet weak var onDmdButton: UIButton!
	@IBOutlet weak var leaveQueueButton: UIButton!
	@IBOutlet weak var currentWaitLabel: UILabel!
	@IBOutlet weak var waitTimeLabel: UILabel!
	@IBOutlet weak var scheduleButton: UIButton!
	
	private var userPlatform: Platform!
	private var monitoringNet: MonitorNetworking!
	private var isPingRunning: Bool = false
	private var foundRoomName: String?
	private var roomRequestTimer: Timer?
	
	override func viewDidLoad() {
		userPlatform = Platform.shared()
		monitoringNet = MonitorNetworking(userPlatform: userPlatform)
		
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		print("viewDidAppear")
		
		fetchWaitTime()
	}
	
	// MARK: - IBAction & Selectors
	
	@IBAction func onDmdButton_Clicked(_ sender: UIButton) {
		if !userPlatform.isInQueue {
			monitoringNet.addUserToQueue(closure: { token, message in
				print("addUserToQueue message: \(message)")
				
				if let retToken = token {
					self.setInQueue(joinQueue: true)
					
					// Fetch room name every 10 seconds. Will wait for request to complete
					self.roomRequestTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { timer in
						if let name = self.foundRoomName {
							// We have the room name cancel the requests
							timer.invalidate()
							
							self.userPlatform.isInQueue = false
							
							// Remove user from queue
							self.monitoringNet.removeUserFromQueue({ message in
								print("Remove user from queue")
							})
							
							// Goto conversations and join the room fam
							let convoVC = self.storyboard?.instantiateViewController(withIdentifier: "convoVC") as! ConversationViewController
							convoVC.token = retToken
							convoVC.reservedRoomId = name
							
							DispatchQueue.main.async {
								self.navigationController?.pushViewController(convoVC, animated: true)
							}
						}
						else if !self.isPingRunning {
							// Fetch for room name
							self.isPingRunning = true
							self.fetchRoomName()
						}
						else {
							// There's probably an error
							timer.invalidate()
							print("An unknown error has occurred")
						}
					})
				}
				else {
					self.showStandardAlert(title: "Monitoring Error", message: "Unable to add user to queue")
				}
			})
		}
	}
	
	@IBAction func leaveQueueButton_Clicked(_ sender: UIButton) {
		if userPlatform.isInQueue {
			// Finish up last requests
			roomRequestTimer?.invalidate()
			
			setInQueue(joinQueue: false)
			
			monitoringNet.removeUserFromQueue({ message in
			})
		}
	}
	
	private func fetchWaitTime() {
		currentWaitLabel.text = "Checking Wait Time"
		
		// Disable on demand button
		onDmdButton.isUserInteractionEnabled = false
		onDmdButton.backgroundColor = UIColor.darkGray
		onDmdButton.isHidden = false
		
		// Perform network request
		monitoringNet.checkWaitTime { isAvailable, waitTimeInMinutes, message in
			if let waitTime = waitTimeInMinutes, isAvailable {
				// There is a monitor available
				self.currentWaitLabel.text = "Current Wait Time"
				self.currentWaitLabel.isHidden = false
				self.waitTimeLabel.text = "< \(waitTime) Minutes"
				self.waitTimeLabel.isHidden = false
				
				if self.userPlatform.isInQueue {
					self.setInQueue(joinQueue: true)
				}
				else {
					// Enable on demand button
					self.setInQueue(joinQueue: false)
					
					self.onDmdButton.isUserInteractionEnabled = true
					self.onDmdButton.backgroundColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
					self.onDmdButton.isHidden = false
				}
			}
			else if !isAvailable && message == "success" {
				// Remove the user from the queue
				self.userPlatform.isInQueue = false
				
				// No monitors available
				self.currentWaitLabel.text = "No Monitors Available"
				self.currentWaitLabel.isHidden = false
				self.waitTimeLabel.isHidden = true
			}
			else {
				// Remove the user from the queue
				self.userPlatform.isInQueue = false
				
				// An error occurred
				self.currentWaitLabel.text = "No Monitors Available"
				self.currentWaitLabel.isHidden = false
				self.waitTimeLabel.isHidden = true
				
				self.showStandardAlert(title: "Monitoring Error", message: message)
			}
		}
	}
	
	private func fetchRoomName() {
		monitoringNet.fetchAssignedRoom { roomName, message in
			if let name = roomName {
				self.foundRoomName = name
			}
			
			self.isPingRunning = false
		}
	}
	
	private func setInQueue(joinQueue: Bool) {
		if joinQueue {
			userPlatform.isInQueue = true
			
			onDmdButton.isHidden = true
			
			queueStatusLabel.text = "In Queue"
			queueStatusLabel.isHidden = false
			
			leaveQueueButton.isHidden = false
		}
		else {
			userPlatform.isInQueue = false
			
			queueStatusLabel.isHidden = true
			leaveQueueButton.isHidden = true
			onDmdButton.isHidden = false
		}
	}
	
	private func showStandardAlert(title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		
		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion: nil)
		}
	}
}
