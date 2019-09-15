//
//  CTSKInlineCameraView.swift
//  Proof
//
//  Created by Steven Fisher on 8/24/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import AVFoundation

class CTSKInlineCameraView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
	
	private var captureSession: AVCaptureSession!
	private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
	private var stillImageOutput: AVCaptureStillImageOutput!
	private var movieFileOutput: AVCaptureMovieFileOutput!
	private var isCameraInitialize: Bool = false
	
	/// Initialization sensor. Defaults to rear facing sensor.
	var camera: CameraOptions = CameraOptions.back
	
	/// When true is recording video
	@objc var isVideoRecording: Bool = false
	
	/// The path where the video is stored
	@objc var finalVideoPath: String = ""
	
	/**
		Camera sensor options
	*/
	enum CameraOptions {
		/// The front facing sensor (selfie) on the device
		case front
		
		/// The rear facing sensor on the device
		case back
	}
	
	/**
		Safely initializes the camera with the front facing sensor. If
		the front facing camera is not available then will use the 
		rear facing sensor.
	*/
    @objc func initializeCameraWithFrontCamera(_ useFrontCamera: Bool, withVideo: Bool) {
		camera = useFrontCamera ? .front : .back
		
        initializeCamera(withVideo: withVideo)
	}
	
	/**
		Initializes the camera with the selected sensor. Connects an
		audio source by default.
	*/
    @objc func initializeCamera(withVideo: Bool) {
		var inputDevice: AVCaptureDevice!
		
		if camera == .front {
			inputDevice = frontCamera()
		}
		else {
			inputDevice = rearCamera()
		}
		
		do {
			let captureInput = try AVCaptureDeviceInput(device: inputDevice)
			
			let captureOutput = AVCaptureVideoDataOutput()
			captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable:NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)] as? [String : Any]
			
			captureSession = AVCaptureSession()
			
			let preset = AVCaptureSession.Preset.medium
			captureSession.sessionPreset = preset
			
            if withVideo {
                let captureAudio = try AVCaptureDeviceInput(device: microphone())

                if captureSession.canAddInput(captureAudio) {
                    captureSession.addInput(captureAudio)
                }
            }
			
			if captureSession.canAddInput(captureInput) {
				captureSession.addInput(captureInput)
			}
			
			if captureSession.canAddOutput(captureOutput) {
				captureSession.addOutput(captureOutput)
			}
			
			if captureVideoPreviewLayer == nil {
				captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
			}
			
			if let previewLayer = captureVideoPreviewLayer {
				previewLayer.frame = self.bounds
				previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
				self.layer.addSublayer(previewLayer)
			}
			
			stillImageOutput = AVCaptureStillImageOutput()
			stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
			captureSession.addOutput(stillImageOutput)
			
			isCameraInitialize = true
			
			movieFileOutput = AVCaptureMovieFileOutput()
		}
		catch(let error) {
            BFLog("Error locking input capturerer = \(error.localizedDescription)")
		}
	}
	
	/**
		Starts the camera preview
	*/
	@objc func showLiveCameraPreview() {
        BFLog("captureSession = \(String(describing: captureSession))")
		captureSession.startRunning()
	}
	
	/**
		Stops the camera preview
	*/
	@objc func hideLiveCameraPreview() {
		captureSession.stopRunning()
	}
	
	/**
		Captures a picture.
	
		- parameter captured: Fired when the picture is taken successfully.
		- parameter image: The image as a UIImage
	*/
	@objc func capturePicture(_ captured: ((_ image: UIImage)->())?) {
		if isCameraInitialize {
			let videoConnection = stillImageOutput.connection(with: AVMediaType.video)
			
			stillImageOutput.captureStillImageAsynchronously(from: videoConnection!, completionHandler: { buffer, error in
				if let err = error {
					print("Error = \(err)")
				}
				else {
					let image = UIImage(data: AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!)!)!
					captured?(image.fixedOrientation())
				}
			})
		}
	}
	
	/**
		Starts video recording and stores the file to the apps local directory
		as a file named 'output.mov'. Removes old file named output.mov if it exists.
	*/
	@objc func startVideoRecording() {
		isVideoRecording = true
		
		captureSession.addOutput(movieFileOutput)
		
		let fileKey = "output.mov"
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let outputPath = NSString(string: paths[0]).appendingPathComponent(fileKey)
		let outputUrl = URL(fileURLWithPath: outputPath)
		let fileManager = FileManager.default
		
		if fileManager.fileExists(atPath: outputPath) {
			do {
				try fileManager.removeItem(at: outputUrl)
			}
			catch {
				print("Error deleting old video file")
			}
		}
		
		finalVideoPath = outputPath
		movieFileOutput.startRecording(to: outputUrl, recordingDelegate: self)
	}
	
	/**
		Stops the video recording process after 2 seconds. Then goes to video 
		processing.
	
		- parameter pausePreview: If true will stop the preview after video recording is completed
	*/
	@objc func stopVideoRecordingAndPausePreview(_ pausePreview: Bool) {
		Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
			self.isVideoRecording = false
			self.movieFileOutput.stopRecording()
			
			if pausePreview {
				self.disconnectCameraPreview()
			}
		}
	}
	
	/**
		Disables the preview on the preview layer.
	*/
	@objc func disconnectCameraPreview() {
		captureVideoPreviewLayer?.connection?.isEnabled = false
	}
	
	/**
		Re-enables the preview on the preview layer.
	*/
	@objc func reconnectCameraPreview() {
		captureVideoPreviewLayer?.connection?.isEnabled = true
	}
	
	func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
		
	}
	
	func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
		if let err = error {
			BFLog("Error = \(err)")
		}
		
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let filePath = NSString(string: paths[0]).appendingPathComponent("output.mp4")
		
		let fileManager = FileManager.default
		if fileManager.fileExists(atPath: filePath) {
			do {
				try fileManager.removeItem(atPath: filePath)
			}
			catch {
				BFLog("Error deleting old final video")
			}
		}
		
		
		let asset = AVAsset(url: URL(fileURLWithPath: outputFileURL.path))
		
		let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
		if let ex = exporter {
			ex.outputFileType = AVFileType.mp4
			ex.outputURL = URL(fileURLWithPath: filePath)
			
			ex.exportAsynchronously(completionHandler: {
				switch ex.status {
				case .completed:
					BFLog("Video completed")
					break
					
				case .cancelled:
					BFLog("Export Cancelled")
					break
					
				case .failed:
					BFLog("Export failed")
					break
					
				case .exporting:
					BFLog("Exporting")
					break
					
				case .unknown:
					BFLog("Export unknown")
					break
					
				case .waiting:
					BFLog("Export waiting")
					break
				}
			})
		}
	}
	
	/**
		Selects the front facing sensor from the device.
	
		- returns: AVCaptureDevice object
	*/
	@objc private func frontCamera() -> AVCaptureDevice {
		return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front)!
	}
	
	/**
		Selects the rear facing sensor from the device.

		- returns: AVCaptureDevice object
	*/
	@objc private func rearCamera() -> AVCaptureDevice {
		return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
	}
	
	/**
		Selects the microphone from the device.
		
		- returns: AVCaptureDevice object
	*/
	@objc private func microphone() -> AVCaptureDevice {
		return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInMicrophone, for: AVMediaType.audio, position: .unspecified)!
	}
}
