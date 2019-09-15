//
//  CheckInOutDashboardViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/12/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD

class CheckInOutDashboardViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var sideMenu: SideMenuController!
	fileprivate var currentUser: Platform = Platform.shared()
	fileprivate var buttonTitles: [[String]] = [[String]]()
	fileprivate var titleId: [Int] = [Int]()
	fileprivate var progressHud: MBProgressHUD? = nil
	fileprivate var meetingCheckInCellFrame: CGRect? = nil
	fileprivate var isMeetingCheckInComplete: Bool = false
	
	// MARK: - Overridden functions
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColorNavBar()
        navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        sideMenu.delegate = self
        setSelected()
		tableView.delegate = self
		tableView.dataSource = self
		
		let defaults = UserDefaults.standard
		isMeetingCheckInComplete = (defaults.string(forKey: "meetingCheckInTime") != nil)
		/*
		// Add facility buttons
		var facilityArr = [String]()
		if currentUser.collectionSiteCheckIn
			|| currentUser.collectionSiteCheckInLocation
			|| currentUser.collectionSiteCheckInSelfie {
			facilityArr.append("Check-In")
		}
		if currentUser.collectionSiteCheckOut
			|| currentUser.collectionSiteCheckOutLocation
			|| currentUser.collectionSiteCheckOutSelfie {
			facilityArr.append("Check-Out")
		}
		if facilityArr.count > 0 {
			titleId.append(0)
			buttonTitles.append(facilityArr)
		}
		*/
		// Add meeting buttons
		var meetingArr = [String]()
		if currentUser.meetingCheckIn
			|| currentUser.meetingCheckInLocation
			|| currentUser.meetingCheckInSelfie {
			meetingArr.append("Check-In")
		}
		if currentUser.meetingCheckOut
			|| currentUser.meetingCheckOutLocation
			|| currentUser.meetingCheckOutSelfie
			|| currentUser.meetingAttendance
			|| currentUser.meetingSignature {
			meetingArr.append("Check-Out")
		}
		if meetingArr.count > 0 {
			titleId.append(1)
			buttonTitles.append(meetingArr)
		}
		
		// Add history button
		if currentUser.globalFacilityCheckInHistory || currentUser.globalMeetingCheckInHistory {
			titleId.append(2)
		}

        
		buttonTitles.append(["View Past Meetings"])
    }
	
	override func viewDidAppear(_ animated: Bool) {
		// Set back button text for the next screens to blank
		        setupColorNavBar()
        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		self.navigationItem.hidesBackButton = true
		self.navigationController?.navigationBar.topItem?.title = "Meetings"
        navigationController?.navigationBar.barStyle = .default
	}
	
	// MARK: - UITableView Delegate
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return currentUser.meetingHistory!.count
        }
        else{
            return buttonTitles[section].count
        }
        
       
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return titleId.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch titleId[section] {
		case 0:
			return "Collection Site"
		case 1:
			return "Meeting"
		case 2:
			return "Meetings History"
		default:
			return ""
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as? ButtonTableViewCell {
            if indexPath.section == 0{
                cell.titleLabel.text = buttonTitles[indexPath.section][indexPath.row]
                cell.accessoryType = .disclosureIndicator
                
                if titleId[indexPath.section] == 1
                    && buttonTitles[indexPath.section][indexPath.row] == "Check-In" {
                    meetingCheckInCellFrame = cell.frame
                    
                    if isMeetingCheckInComplete {
                        cell.accessoryType = .checkmark
                    }
                }
            }
            else{
                if let checkInDate = currentUser.meetingHistory![indexPath.row].checkInDate {
                    cell.titleLabel.text = checkInDate
                }
                else if let checkOutDate = currentUser.meetingHistory![indexPath.row].checkInDate {
                    cell.titleLabel.text = checkOutDate
                }
//                cell.titleLabel.text = ""
                cell.accessoryType = .disclosureIndicator
                
                if titleId[indexPath.section] == 1
                    && buttonTitles[indexPath.section][indexPath.row] == "Check-In" {
                    meetingCheckInCellFrame = cell.frame
                    
                    if isMeetingCheckInComplete {
                        cell.accessoryType = .checkmark
                    }
                }
            }
			
			
			return cell
		}
		else {
			let cell = ButtonTableViewCell()
//            if let checkInDate = meetingHistory[indexPath.row].checkInDate {
//                cell.titleLabel.text = checkInDate
//            }
//            else if let checkOutDate = meetingHistory[indexPath.row].checkOutDate {
//                cell.titleLabel.text = checkOutDate
//            }
			cell.titleLabel.text = buttonTitles[indexPath.section][indexPath.row]
			cell.accessoryType = .disclosureIndicator
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		switch titleId[indexPath.section] {
		case 0:
			let currentButtonTitle = buttonTitles[indexPath.section][indexPath.row]
			
			if currentButtonTitle == "Check-In" { gotoCheckIn(true) }
			if currentButtonTitle == "Check-Out" { gotoCheckOut(true) }
		case 1:
			let currentButtonTitle = buttonTitles[indexPath.section][indexPath.row]
			
			if currentButtonTitle == "Check-In" { gotoCheckIn(false) }
			if currentButtonTitle == "Check-Out" { gotoCheckOut(false) }
			
		case 2:
            gotoHistory(index: indexPath.row)
			
		default:
			break
		}
	}
	
	fileprivate func gotoCheckIn(_ isFacility: Bool) {
		currentUser.checkinorout = "checkin"
		
		if isFacility {
			currentUser.checkInType = "facilitycheckincheckout"
            if(self.currentUser.cocNumber || self.currentUser.cocOptionNumber){
                self.showCOCAlert()
            }else if(self.currentUser.cocObserved){
                self.showCOCObservedAlert()
            }else{
                branchGotoNextVCCheckInFacility()
            }
		}
		else {
			let defaults = UserDefaults.standard
			if let meetingCheckInTime = defaults.string(forKey: "meetingCheckInTime") {
				let alert = UIAlertController(title: "Check In Error", message: "You must complete the Check Out for the previous date before you can Check In again!\n\nLast Check In:\n\(meetingCheckInTime)", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				
				DispatchQueue.main.async {
					self.present(alert, animated: true, completion: nil)
				}
			}
			else {
				currentUser.checkInType = "meetingcheckincheckout"
				showAlertIfMeetingTypesAvailable(true)
			}
		}
	}
	
	fileprivate func gotoCheckOut(_ isFacility: Bool) {
		currentUser.checkinorout = "checkout"
		
		if isFacility {
			//currentUser.checkInType = "facilitycheckincheckout"
            //if(self.currentUser.cocFormCheckOut){
             //   showCOCAlert()
            //}else{
                branchGotoNextVCCheckOutFacility()
            //}
		}
		else {
			let defaults = UserDefaults.standard
			if let meetingType = defaults.string(forKey: "SavedMeetingType") {
				BFLog("Previous meeting type = \(meetingType)")
				
				currentUser.meetingType = meetingType
				currentUser.checkInType = "meetingcheckincheckout"
				
				if currentUser.globalTopic {
					showMeetingTopicAlert()
				}
				else {
					branchGotoNextVCCheckOutMeeting()
				}
			}
			else {
				let alert = UIAlertController(title: "Unable to checkout", message: "You have not completed a check in before checking out. Please complete a meeting checkin and return to complete a meeting checkout", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}
		}
	}

    fileprivate func gotoHistory(index: Int) {
		/*let checkInOutHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "checkInOutHistoryVC")
		self.navigationController?.pushViewController(checkInOutHistoryVC!, animated: true)*/
        var tempData = [String]()
        if let checkinDate = currentUser.meetingHistory![index].checkInDate {
            tempData.append("Check-In: \(checkinDate)")
        }
        
        if let checkOutDate = currentUser.meetingHistory![index].checkOutDate {
            tempData.append("Check-Out: \(checkOutDate)")
        }
        
        if let meetingType = currentUser.meetingHistory![index].meetingType, !meetingType.isEmpty {
            tempData.append("Type: \(meetingType)")
        }
        
        if let meetingTopic = currentUser.meetingHistory![index].meetingTopic, !meetingTopic.isEmpty {
            tempData.append("Topic: \(meetingTopic)")
        }
        
        if let meetingName = currentUser.meetingHistory![index].meetingName, !meetingName.isEmpty {
            tempData.append("Name: \(meetingName)")
        }
        let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "historyVC") as! HistoryViewController
        historyVC.vcTitle = "Meeting History"
        historyVC.data = tempData
        self.navigationController?.pushViewController(historyVC, animated: true)
	}
	
	fileprivate func showAlertIfMeetingTypesAvailable(_ isCheckIn: Bool) {
		// Only show meeting types if the user has meeting types
		if currentUser.meetingTypes != nil && currentUser.meetingTypes!.count > 0 {
			let alert = UIAlertController(title: "Select Meeting Type", message: nil, preferredStyle: .actionSheet)
			
			for meetingType in currentUser.meetingTypes! {
				let alertAction = UIAlertAction(title: meetingType, style: .default, handler: { action in
                    guard meetingType != "Other Meeting Type" else {
                        DispatchQueue.main.async {
                            self.showCustomMeetingTypeAlert(isCheckIn)
                        }

                        return
                    }

					self.currentUser.meetingType = meetingType
					
					if isCheckIn {
						if self.currentUser.meetingCheckInName {
							self.showMeetingNameAlert()
						}
						else {
							self.branchGotoNextVCCheckInMeeting()
						}
					}
					else {
						self.branchGotoNextVCCheckOutMeeting()
					}
				})
				
				alert.addAction(alertAction)
			}
			
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			alert.addAction(cancelAction)
			
			alert.popoverPresentationController?.sourceView = self.view
			
			if let frame = meetingCheckInCellFrame {
				alert.popoverPresentationController?.sourceRect = frame
			}
			else {
				alert.popoverPresentationController?.sourceRect = self.view.bounds
			}
			
			self.present(alert, animated: true, completion: nil)
		}
		else {
			// User has no meeting types
			currentUser.meetingType = ""
			
			BFLog("No meeting types found")
			
			if isCheckIn {
				if self.currentUser.meetingCheckInName {
					self.showMeetingNameAlert()
				}
				else {
					self.branchGotoNextVCCheckInMeeting()
				}
			}
			else {
				branchGotoNextVCCheckOutMeeting()
			}
		}
	}
	
	fileprivate func showMeetingTopicAlert() {
		let alert = UIAlertController(title: "Meeting Topic", message: "Enter the topic of the meeting.", preferredStyle: .alert)
		
		let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
			if let textFields = alert.textFields, let text = textFields[0].text {
				var alertBody = "Meeting topic is invalid!"
				
				// Trim the text to remove spaces and new line characters
				let meetingTopicText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if meetingTopicText.count > 255 {
                    alertBody = "Meeting topic cannot have more than 255 characters."
                }
				else if meetingTopicText.count <= 0 {
					alertBody = "Meeting topic cannot be empty."
				}
				else {
					self.currentUser.meetingTopic = meetingTopicText
					
					self.branchGotoNextVCCheckOutMeeting()
					return
				}
				
				let valErrorAlert = UIAlertController(title: "Invalid Meeting Topic", message: alertBody, preferredStyle: .alert)
				valErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
					self.showMeetingTopicAlert()
				}))
				
				DispatchQueue.main.async {
					self.present(valErrorAlert, animated: true, completion: nil)
				}
			}
		})
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alert.addAction(doneAction)
		alert.addAction(cancelAction)
		alert.addTextField(configurationHandler: nil)
		
		DispatchQueue.main.async {
			self.present(alert, animated: true, completion: nil)
		}
	}
    fileprivate func showCOCObservedAlert() {
        let alert = UIAlertController(title: "COC Log Data", message:"COC Observed?", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.currentUser.cocObservedText = true
                self.branchGotoNextVCCheckInFacility()
                return
            //}else if(self.currentUser.checkinorout == "checkout"){
            //    self.branchGotoNextVCCheckOutFacility()
            //    return
            //}
            //else{
            //    return
            //}
            
        })
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.currentUser.cocObservedText = false
            //if(self.currentUser.checkinorout == "checkin"){
                self.branchGotoNextVCCheckInFacility()
                return
            //}else if(self.currentUser.checkinorout == "checkout"){
            //   self.branchGotoNextVCCheckOutFacility()
            //    return
            //}
            //else{
            //    return
            //}
            
        })
        
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    fileprivate func showCOCAlert() {
        let alert = UIAlertController(title: "COC Log Data", message:"", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
            if let textFields = alert.textFields{
                if(self.currentUser.cocNumber){
                    let cocNumber = textFields[0].text
                    let cocNumberText = cocNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.currentUser.cocNumberText = cocNumberText ?? ""
                }
                if(self.currentUser.cocOptionNumber){
                    var index: Int = 0;
                    if(self.currentUser.cocNumber){
                        index += 1;
                    }
                    let cocOptionNumber = textFields[index].text
                    let cocOptionNumberText = cocOptionNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.currentUser.cocOptionNumberText = cocOptionNumberText ?? ""
                }
                if(self.currentUser.cocObserved){
                    self.showCOCObservedAlert()
                }else{
                    if(self.currentUser.checkinorout == "checkin"){
                        self.branchGotoNextVCCheckInFacility()
                        return
                    }else if(self.currentUser.checkinorout == "checkout"){
                        self.branchGotoNextVCCheckOutFacility()
                        return
                    }
                    else{
                        return
                    }
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        if(self.currentUser.cocNumber){
            alert.addTextField{ (cocNumber) in
                cocNumber.placeholder = "COC Number"
            }
        }
        if(self.currentUser.cocOptionNumber){
            alert.addTextField{ (cocOptNumber) in
                cocOptNumber.placeholder = "COC Option Number"
            }
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
	fileprivate func showMeetingNameAlert() {
		let alert = UIAlertController(title: "Meeting name", message: "Enter a name for this meeting.", preferredStyle: .alert)
		
		let doneAction = UIAlertAction(title: "Done", style: .default) { action in
			if let textFields = alert.textFields, let text = textFields[0].text {
				var alertBody = "Meeting name is invalid!"
				
				// Trim the text to remove spaces and new line characters
				let meetingNameText = text.trimmingCharacters(in: .whitespacesAndNewlines)
				if meetingNameText.count > 255 {
					alertBody = "Meeting name cannot have more than 255 characters."
				}
				else if meetingNameText.count <= 0 {
					alertBody = "Meeting name cannot be empty."
				}
				else {
					let defaults = UserDefaults.standard
					defaults.setValue(text, forKey: "STORED_MEETING_NAME")
					defaults.synchronize()
					
					self.branchGotoNextVCCheckInMeeting()
					return
				}
				
				let valErrorAlert = UIAlertController(title: "Invalid Meeting Name", message: alertBody, preferredStyle: .alert)
				valErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
					self.showMeetingNameAlert()
				}))
				
				DispatchQueue.main.async {
					self.present(valErrorAlert, animated: true, completion: nil)
				}
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alert.addAction(doneAction)
		alert.addAction(cancelAction)
		
		alert.addTextField(configurationHandler: nil)
		
		self.present(alert, animated: true, completion: nil)
	}

    fileprivate func showCustomMeetingTypeAlert(_ isCheckIn: Bool) {
        let alert = UIAlertController(title: "Other Meeting Type", message: "Enter a meeting type", preferredStyle: .alert)

        let doneAction = UIAlertAction(title: "Done", style: .default) { action in
            if let textFields = alert.textFields, let text = textFields[0].text {
                var alertBody = "Meeting Type is invalid!"

                let meetingTypeText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if meetingTypeText.count > 255 {
                    alertBody = "Meeting type cannot have more than 255 characters."
                }
                else if meetingTypeText.count <= 0 {
                    alertBody = "Meeting type cannot be empty."
                }
                else {
                    self.currentUser.meetingType = meetingTypeText

                    if isCheckIn {
                        if self.currentUser.meetingCheckInName {
                            self.showMeetingNameAlert()
                        }
                        else {
                            self.branchGotoNextVCCheckInMeeting()
                        }
                    }
                    else {
                        self.branchGotoNextVCCheckOutMeeting()
                    }

                    return
                }

                let valErrorAlert = UIAlertController(title: "Invalid Meeting Type", message: alertBody, preferredStyle: .alert)
                valErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.showMeetingNameAlert()
                }))

                DispatchQueue.main.async {
                    self.present(valErrorAlert, animated: true, completion: nil)
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(doneAction)
        alert.addAction(cancelAction)

        alert.addTextField(configurationHandler: nil)

        self.present(alert, animated: true, completion: nil)
    }
	
	/**
	 * Decides what VC comes next depending on constraints for FacilityCheckIn
	 */
	fileprivate func branchGotoNextVCCheckInFacility() {
		if self.currentUser.collectionSiteCheckInLocation {
			let checkInOut = self.storyboard?.instantiateViewController(withIdentifier: "checkInOut") as! CheckInLocationViewController
			checkInOut.isSelfieRequired = self.currentUser.collectionSiteCheckInSelfie
            checkInOut.isFormRequired = self.currentUser.cocFormCheckIn
			self.navigationController?.pushViewController(checkInOut, animated: true)
		}
		else if self.currentUser.collectionSiteCheckInSelfie {
			let checkInSelfie = self.storyboard?.instantiateViewController(withIdentifier: "checkInSelfie") as! CheckInSelfieViewController
            checkInSelfie.isFormPictureRequired = self.currentUser.cocFormCheckIn
			self.navigationController?.pushViewController(checkInSelfie, animated: true)
		}
        else if self.currentUser.cocFormCheckIn{
            let cocFormCheckInPicture = self.storyboard?.instantiateViewController(withIdentifier: "formCheckInView") as! FormPictureController
            self.navigationController?.pushViewController(cocFormCheckInPicture, animated: true)
        }
		else {
			progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
			progressHud?.label.text = "Uploading"
			
			// Location and selfie aren't required send the request
			sendBlankRequest(true, isMeeting: false)
		}
	}
	
	/**
	 * Decides what VC comes next depending on constraints for FacilityCheckOut
	 */
	fileprivate func branchGotoNextVCCheckOutFacility() {
		if self.currentUser.collectionSiteCheckOutLocation {
			let checkOut = self.storyboard?.instantiateViewController(withIdentifier: "checkOut") as! CheckOut
			checkOut.isSelfieRequired = self.currentUser.collectionSiteCheckOutSelfie
            checkOut.isFormPictureRequired = self.currentUser.cocFormCheckOut
			self.navigationController?.pushViewController(checkOut, animated: true)
		}
		else if self.currentUser.collectionSiteCheckOutSelfie {
			let checkOutSelfie = self.storyboard?.instantiateViewController(withIdentifier: "checkOutSelfie") as! CheckOutSelfieViewController
            checkOutSelfie.isFormPictureRequired = self.currentUser.cocFormCheckOut
			self.navigationController?.pushViewController(checkOutSelfie, animated: true)
		}
        else if self.currentUser.cocFormCheckOut{
            let cocFormCheckInPicture = self.storyboard?.instantiateViewController(withIdentifier: "formCheckInView") as! FormPictureController
            self.navigationController?.pushViewController(cocFormCheckInPicture, animated: true)
        }
		else {
			progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
			progressHud?.label.text = "Uploading"
			
			// Location and selfie aren't required send the request
			sendBlankRequest(false, isMeeting: false)
		}
	}
	
	/**
	 * Decides what VC comes next depending on constraints for MeetingCheckIn
	 */
	fileprivate func branchGotoNextVCCheckInMeeting() {
       
        if self.currentUser.meetingCheckInLocation {
            let checkInOut = self.storyboard?.instantiateViewController(withIdentifier: "checkInOut") as! CheckInLocationViewController
            checkInOut.isSelfieRequired = self.currentUser.meetingCheckInSelfie
            checkInOut.isAttendanceRequired = self.currentUser.meetingCheckInAttendance
            checkInOut.isSignatureRequired = self.currentUser.meetingCheckInSignature
            checkInOut.isMeeting = true
            self.navigationController?.pushViewController(checkInOut, animated: true)
        }
        else if self.currentUser.meetingCheckInSelfie {
            let checkInOut = self.storyboard?.instantiateViewController(withIdentifier: "checkInSelfie") as! CheckInSelfieViewController
            checkInOut.isSignatureRequired = self.currentUser.meetingCheckInSignature
            checkInOut.isMeeting = true
            self.navigationController?.pushViewController(checkInOut, animated: true)
        }
        else if self.currentUser.meetingCheckInAttendance {
            let attendanceView = self.storyboard?.instantiateViewController(withIdentifier: "attendanceView") as! AttendanceViewController
            attendanceView.isSignatureRequired = self.currentUser.meetingCheckInSignature
            self.navigationController?.pushViewController(attendanceView, animated: true)
        }
        else if self.currentUser.meetingCheckInSignature {
            let signatureView = self.storyboard?.instantiateViewController(withIdentifier: "signatureView") as! SignatureViewController
            self.navigationController?.pushViewController(signatureView, animated: true)
        }
        else {
            progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHud?.label.text = "Uploading"
            
            // Location and selfie aren't required send the request
            sendBlankRequest(true, isMeeting: true)
        }
        
		
	}
	
	/**
	 * Decides what VC comes next depending on constraints for MeetingCheckOut
	 */
	fileprivate func branchGotoNextVCCheckOutMeeting() {
        
        if currentUser.meetingCheckOutLocation {
            let checkOut = self.storyboard?.instantiateViewController(withIdentifier: "checkOut") as! CheckOut
            checkOut.isAttendanceRequired = self.currentUser.meetingAttendance
            checkOut.isSignatureRequired = self.currentUser.meetingSignature
            checkOut.isSelfieRequired = self.currentUser.meetingCheckOutSelfie
            self.navigationController?.pushViewController(checkOut, animated: true)
        }
        else if currentUser.meetingCheckOutSelfie {
            let checkOutSelfie = self.storyboard?.instantiateViewController(withIdentifier: "checkOutSelfie") as! CheckOutSelfieViewController
            checkOutSelfie.isAttendanceRequired = self.currentUser.meetingAttendance
            checkOutSelfie.isSignatureRequired = self.currentUser.meetingSignature
            self.navigationController?.pushViewController(checkOutSelfie, animated: true)
        }
        else if currentUser.meetingAttendance {
            let checkOutAttendance = self.storyboard?.instantiateViewController(withIdentifier: "attendanceView") as! AttendanceViewController
            checkOutAttendance.isSignatureRequired = self.currentUser.meetingSignature
            self.navigationController?.pushViewController(checkOutAttendance, animated: true)
        }
        else if currentUser.meetingSignature {
            let checkOutSignature = self.storyboard?.instantiateViewController(withIdentifier: "signatureView") as! SignatureViewController
            self.navigationController?.pushViewController(checkOutSignature, animated: true)
        }
        else {
            progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHud?.label.text = "Uploading"
            
            // Location and selfie aren't required send the request
            sendBlankRequest(false, isMeeting: true)
        }
        
		
	}
	
	/**
	 * Sends a blank request when the user doesn't have permissions other than the
	 * standard CheckIn/Out permission
	 */
	fileprivate func sendBlankRequest(_ isCheckIn: Bool, isMeeting: Bool) {
		let checkInOutRequest = NTCheckInOutRequest(baseUrl: self.currentUser.baseUrl, participantId: self.currentUser.globalPartId, pin: self.currentUser.globalPin,
		                                            checkInType: self.currentUser.checkInType, action: (isCheckIn) ? "checkin" : "checkout", gpsLat: "0.00",
		                                            gpsLong: "0.00", meetingType: self.currentUser.meetingType)
		
		checkInOutRequest.sendRequest { message in
            self.progressHud?.hide(animated: true)

            var alertTitle = (isCheckIn) ? "Check-In" : "Check-Out"

            if (message == "success" || !isMeeting) {
                if isMeeting && message == "success" {
                    let defaults = UserDefaults.standard

                    if isCheckIn {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MM/dd/yyyy h:mm a"
                        if self.currentUser.checkInType == "facilitycheckincheckout" {
                            defaults.set(formatter.string(from: Date()), forKey: "facilityCheckInTime")
                            defaults.set(self.currentUser.meetingType, forKey: "SavedMeetingType")
                        }else{
                            defaults.set(formatter.string(from: Date()), forKey: "meetingCheckInTime")
                            defaults.set(self.currentUser.meetingType, forKey: "SavedMeetingType")
                            self.isMeetingCheckInComplete = true
                        }
                        defaults.synchronize()

                        
                    }
                    else {
                        defaults.removeObject(forKey: "SavedMeetingType")
                        defaults.removeObject(forKey: "STORED_MEETING_NAME")
                        defaults.removeObject(forKey: "meetingCheckInTime")
                        if self.currentUser.checkInType != "facilitycheckincheckout" {
                            self.isMeetingCheckInComplete = false
                        }
                    }

                    defaults.synchronize()

                    self.tableView.reloadData()
                }

                let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                alertTitle += " Error";
                let errorMessage = "An error occurred while saving your meeting record. Your meeting was not recorded, please try again.";
                let alert = UIAlertController(title: alertTitle, message: errorMessage, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                    self.sendBlankRequest(isCheckIn, isMeeting: isMeeting)
                }))

                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
		}
	}
    func setSelected(){
        sideMenu.mettingSelected()
    }
}
extension CheckInOutDashboardViewController: SideMenuDelegate{
    func surveyTapped() {
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    func testStatusTapped() {
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "testStatusDash") as! TestStatusDashboardViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func mettingTapped() {
        // Do nothing as it is on the required page
        //        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "checkInOutDash") as! CheckInOutDashboardViewController
        //        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func sitesTapped() {
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "nearestColSitesView") as! NearestCollectionSitesViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func bacTestTapped() {
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "bacDash") as! BACTestDashboardViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func supportTapped() {
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "supportView") as! SupportViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func logoutTapped() {
        //        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController")
        //        self.navigationController?.pushViewController(loginVC!, animated: false)
        AppStateManager.sharedInstance.loadLogin()
    }
    
    
}
