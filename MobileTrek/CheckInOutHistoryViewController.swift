//
//  CheckInOutHistoryViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/19/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD

class CheckInOutHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	
	fileprivate let currentUser = Platform.shared()
	fileprivate var showFacilityHistory: Bool = false
	fileprivate var showMeetingHistory: Bool = false
	fileprivate var facilityHistory = [FacilityHistory]()
	fileprivate var meetingHistory = [MeetingHistory]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.isHidden = true
		
		showFacilityHistory = currentUser.globalFacilityCheckInHistory
		showMeetingHistory = currentUser.globalMeetingCheckInHistory
		
        tableView.delegate = self
		tableView.dataSource = self
		
		reloadHistory()
    }
	
	private func reloadHistory() {
		let progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
		progressHud.label.text = "Loading..."
		
		NTHistoryRequest(baseUrl: currentUser.baseUrl, participantId: currentUser.globalPartId, pin: currentUser.globalPin)
		.sendRequest { success, message, checkInStatusHistory, facilityCheckInOutHistory, meetingCheckInOutHistory, bacHistory in
			DispatchQueue.main.async {
				MBProgressHUD.hide(for: self.view, animated: true)
			}
			
			if success {
				self.currentUser.checkInStatusHistory = checkInStatusHistory
				self.currentUser.bacTestHistory = bacHistory
				
				self.facilityHistory = facilityCheckInOutHistory ?? [FacilityHistory]()
				self.meetingHistory = meetingCheckInOutHistory ?? [MeetingHistory]()
				
				print("meetingHistory count: \(self.meetingHistory.count)")
				
				self.tableView.reloadData()
				self.tableView.isHidden = false
			}
			else {
				let alert = UIAlertController(title: "History Error", message: message, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				
				DispatchQueue.main.async {
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if tableView.isHidden {
			let view = UIView()
			view.backgroundColor = UIColor.red
			
			return view
		}
		
		return nil
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if facilityHistory.count > 0 || meetingHistory.count > 0 {
			if showFacilityHistory && section == 0 {
				return "Collection Site Check-In/Out"
			}
			else if showMeetingHistory {
				return "Meetings"
			}
		}
		
		return nil
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if showFacilityHistory && showMeetingHistory {
			return 2
		}
		else if showFacilityHistory || showMeetingHistory {
			return 1
		}
		
		return 0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if currentUser.globalFacilityCheckInHistory && section == 0 {
			return facilityHistory.count
		}
		else if currentUser.globalMeetingCheckInHistory {
			return meetingHistory.count
		}
		
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
		
		if showFacilityHistory && indexPath.section == 0 {
			if let checkInDate = facilityHistory[indexPath.row].checkInDate {
				cell.titleLabel.text = checkInDate
			}
			else if let checkOutDate = facilityHistory[indexPath.row].checkOutDate {
				cell.titleLabel.text = checkOutDate
			}
		}
		else if showMeetingHistory {
			if let checkInDate = meetingHistory[indexPath.row].checkInDate {
				cell.titleLabel.text = checkInDate
			}
			else if let checkOutDate = meetingHistory[indexPath.row].checkOutDate {
				cell.titleLabel.text = checkOutDate
			}
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		var tempData = [String]()
		
		if showFacilityHistory && indexPath.section == 0 {
			if let checkinDate = facilityHistory[indexPath.row].checkInDate {
				tempData.append("Check-In: \(checkinDate)")
			}
			
			if let checkOutDate = facilityHistory[indexPath.row].checkOutDate {
				tempData.append("Check-Out: \(checkOutDate)")
			}
		}
		else {
			if let checkinDate = meetingHistory[indexPath.row].checkInDate {
				tempData.append("Check-In: \(checkinDate)")
			}
			
			if let checkOutDate = meetingHistory[indexPath.row].checkOutDate {
				tempData.append("Check-Out: \(checkOutDate)")
			}
			
			if let meetingType = meetingHistory[indexPath.row].meetingType, !meetingType.isEmpty {
				tempData.append("Type: \(meetingType)")
			}
			
			if let meetingTopic = meetingHistory[indexPath.row].meetingTopic, !meetingTopic.isEmpty {
				tempData.append("Topic: \(meetingTopic)")
			}
			
			if let meetingName = meetingHistory[indexPath.row].meetingName, !meetingName.isEmpty {
				tempData.append("Name: \(meetingName)")
			}
		}
		
		let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "historyVC") as! HistoryViewController
		historyVC.vcTitle = "Meeting History"
		historyVC.data = tempData
		self.navigationController?.pushViewController(historyVC, animated: true)
	}

}
