//
//  ConversationViewController.swift
//  BadgerTrek
//
//  Created by Steven Fisher on 1/6/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import TwilioVideo

class ConversationViewController: UIViewController {
	
	@IBOutlet weak var localVideoContainer: TVIVideoView!
	@IBOutlet weak var remoteVideoContainer: TVIVideoView!
	@IBOutlet weak var muteImageView: UIImageView!
	@IBOutlet weak var endCallImageView: UIImageView!
	
	var token: String = ""
	var reservedRoomId: String = ""
	
	var room: TVIRoom?
	var camera: TVICameraCapturer!
	var localVideoTrack: TVILocalVideoTrack?
	var localAudioTrack: TVILocalAudioTrack?
	var participant: TVIRemoteParticipant?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard !token.isEmpty else {
			print("Unable to retrieve token")
			return
		}
		
		guard !reservedRoomId.isEmpty else {
			print("Invalid reservation id")
			return
		}
		
		// Add mic gesture recog
		let micGestureRecog = UITapGestureRecognizer(target: self, action: #selector(micToggle_Clicked))
		muteImageView.isUserInteractionEnabled = true
		muteImageView.addGestureRecognizer(micGestureRecog)
		
		// Add end call gesture recog
		let endCallRecog = UITapGestureRecognizer(target: self, action: #selector(endCall_Clicked))
		endCallImageView.isUserInteractionEnabled = true
		endCallImageView.addGestureRecognizer(endCallRecog)
		
		startPreview()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	private func prepareLocalMedia() {
		if localAudioTrack == nil {
			localAudioTrack = TVILocalAudioTrack()
		}
		
		if localVideoTrack == nil {
			startPreview()
		}
	}
	
	private func startPreview() {
		camera = TVICameraCapturer()
		
		localVideoTrack = TVILocalVideoTrack(capturer: camera)
		if localVideoTrack == nil {
			print("Failed to add video track")
		}
		else {
			localVideoTrack!.addRenderer(localVideoContainer)
			
			print("Video track added to localMedia")
			
			connect()
		}
	}
	
	private func connect() {
		prepareLocalMedia()
        
		let connectOptions = TVIConnectOptions.init(token: token) { builder in
			builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [TVILocalAudioTrack]()
			builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [TVILocalVideoTrack]()
			
			builder.roomName = self.reservedRoomId
		}
		
		room = TwilioVideo.connect(with: connectOptions, delegate: self)
		
		print("Attempting to connnect to room with reservation id: \(reservedRoomId)")
	}
	
	func cleanupRemoteParticipant() {
		if let pct = participant, pct.videoTracks.count > 0 {
//            pct.videoTracks[0].removeRenderer(remoteVideoContainer)
			remoteVideoContainer.removeFromSuperview()
			remoteVideoContainer = nil
		}
		
		participant = nil
	}
	
	// MARK: IBAction & Selectors
	
	@objc func micToggle_Clicked() {
		if let localAudio = localAudioTrack {
			localAudio.isEnabled = !localAudio.isEnabled
			
			// Set mute image
			muteImageView.image = (localAudio.isEnabled) ? #imageLiteral(resourceName: "mic_mute") : #imageLiteral(resourceName: "mic")
		}
	}
	
	@objc func endCall_Clicked() {
		let alertController = UIAlertController(title: "End Monitoring Call", message: "Are you sure you want to end the monitoring call?", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
		alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
			self.room?.disconnect()
            
            
			
			DispatchQueue.main.async {
				_ = self.navigationController?.popViewController(animated: true)
			}
		}))
		
		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion: nil)
		}
	}
}

// MARK: TVIRoomDelegate

extension ConversationViewController : TVIRoomDelegate {
	func didConnect(to room: TVIRoom) {		
		// At the moment, this example only supports rendering one Participant at a time.
		
        print("didConnect remoteParticipants:\(room.remoteParticipants.count)")
        
        self.participant = room.remoteParticipants[0]
        self.participant?.delegate = self
	}
	
	func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
		self.cleanupRemoteParticipant()
		self.room = nil
	}
	
	func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
		print("Failed to connect to room with error")
		self.room = nil
	}
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIRemoteParticipant) {
        if self.participant == nil {
            self.participant = participant
            self.participant?.delegate = self
        }
        
        print("Room \(room.name), Participant \(participant.identity) connected")
    }
	
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIRemoteParticipant) {
        room.disconnect()
        
        let alert = UIAlertController(title: "Call Ended", message: "The Monitor has ended the call.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        print("Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

// MARK: TVIRemoteParticipantDelegate

extension ConversationViewController : TVIRemoteParticipantDelegate {
    func subscribed(to videoTrack: TVIRemoteVideoTrack, publication: TVIRemoteVideoTrackPublication, for participant: TVIRemoteParticipant) {
        print("Subscribed to video track")
        
        publication.remoteTrack?.addRenderer(remoteVideoContainer)
    }
	
	func participant(_ participant: TVIParticipant, removedVideoTrack videoTrack: TVIVideoTrack) {
		print("Participant \(participant.identity) removed video track")
		
		if (self.participant == participant) {
			videoTrack.removeRenderer(remoteVideoContainer)
		}
	}
	
	func participant(_ participant: TVIParticipant, addedAudioTrack audioTrack: TVIAudioTrack) {
		print("Participant \(participant.identity) added audio track")
		
	}
	
	func participant(_ participant: TVIParticipant, removedAudioTrack audioTrack: TVIAudioTrack) {
		print("Participant \(participant.identity) removed audio track")
	}
	
	func participant(_ participant: TVIParticipant, enabledTrack track: TVITrack) {
		var type = ""
		if track is TVIVideoTrack {
			type = "video"
		}
		else {
			type = "audio"
		}
		print("Participant \(participant.identity) enabled \(type) track")
	}
	
	func participant(_ participant: TVIParticipant, disabledTrack track: TVITrack) {
		var type = ""
		if track is TVIVideoTrack {
			type = "video"
		}
		else {
			type = "audio"
		}
		print("Participant \(participant.identity) disabled \(type) track")
	}
}
