//
//  AWSUploader.swift
//  Proof
//
//  Created by Steven Fisher on 8/24/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import AWSS3

class AWSUploader: NSObject {

	private static var currentUploadTask: AWSS3TransferUtilityUploadTask? = nil
	
	static func uploadRequest(uploadKey: String,
                              filePath: String,
                              bucket: AWSBuckets,
                              progress: ((_ finished: Float)->())?,
                              finished: ((_ url: String)->())?,
                              error: ((_ errorMessage: String)->())?) {
		let transferManager = AWSS3TransferManager.default()
		
		if let request = AWSS3TransferManagerUploadRequest() {
			request.bucket = bucket.rawValue
			request.key = uploadKey
			request.body = URL(fileURLWithPath: filePath)
			request.uploadProgress = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
				progress?(Float(totalBytesSent / totalBytesExpectedToSend))
			}
			
			transferManager.upload(request).continueWith(block: { task -> Any? in
				if let err = task.error {
					error?(err.localizedDescription)
				}
                else if task.result != nil {
					finished?(uploadKey)
				}
				
				return nil
			})
		}
		else {
			print("upload request is nil!")
		}
	}

    enum AWSBuckets: String {
        case bactestVideos = "rt-mobiletrek"
        case bactestPics = "recoverytrekbacpics"
    }
}
