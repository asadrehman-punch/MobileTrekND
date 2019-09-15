//
//  BACTestResult.swift
//  MobileTrek
//
//  Created by Steve Fisher on 11/5/18.
//  Copyright © 2018 RecoveryTrek. All rights reserved.
//

import SharkORM
import Alamofire

class BACTestResult : SRKObject {
    
    @objc dynamic var programUrl: String!
    @objc dynamic var partId: String!
    @objc dynamic var partPin: String!
    @objc dynamic var gpsLat: String!
    @objc dynamic var gpsLong: String!
    @objc dynamic var bracLevel: String!
    @objc dynamic var bracResult: String!
    @objc dynamic var submitted: String!
    @objc dynamic var mediaPath: String!
    @objc dynamic var imageUrl: String?
    @objc dynamic var videoUrl: String?
    @objc dynamic var encodedImage: String?
    @objc dynamic var isVideo: Bool = false
    @objc dynamic var isFacialRecogEnabled: Bool = false
    @objc dynamic var uploadFailureCount: Int = 0
    
    func upload(completed: ((_ message: String) -> Void)?) {
        let bucket = isVideo ? AWSUploader.AWSBuckets.bactestVideos : AWSUploader.AWSBuckets.bactestPics
        let timeNow = Date()
        let unixTime = String(Int(timeNow.timeIntervalSince1970))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM_dd_yyyy-HH_mm_ss"
        
        let fileType = isVideo ? ".mp4" : ".jpeg"
        let uploadKey = "\(partId ?? "000000000")/\(unixTime)\(fileType)"
        
        var mediaFilePath: URL!
        
        if self.id != nil {
            mediaFilePath = getDocsPathURL()
                .appendingPathComponent("uploadpending")
                .appendingPathComponent(mediaPath)
        }
        else {
            mediaFilePath = URL(fileURLWithPath: mediaPath)
        }
        
        if isFacialRecogEnabled || isVideo {
            if (videoUrl == nil && imageUrl == nil) {
                // We need to attempt AWS Upload first
                AWSUploader.uploadRequest(uploadKey: uploadKey, filePath: mediaFilePath.path, bucket: bucket, progress: { progress in
                    print("progress = \(progress)")
                }, finished: { finalUrl in
                    if self.isVideo {
                        self.videoUrl = "https://s3.amazonaws.com/rt-mobiletrek/\(finalUrl)"
                    }
                    else {
                        self.imageUrl = finalUrl
                    }
                    
                    self.salesforceRequest { responseMessage in
                        if responseMessage == "success" {
                            BFLog("Salesforce request successful")
                            
                            do {
                                try FileManager.default.removeItem(at: mediaFilePath)
                            }
                            catch {
                                print("Unable to remove mediaFilePath = \(error.localizedDescription)")
                            }
                            
                            if self.id != nil {
                                self.remove()
                            }
                            completed?(responseMessage)
                        }
                        else {
                            BFLog("Unable to send request: \(responseMessage)")
                            
                            self.storeTest(timestamp: unixTime, fileType: fileType)
                            completed?(responseMessage)
                        }
                    }
                }) { errorMessage in
                    BFLog("Unable to upload image to AWS = \(errorMessage)")
                    
                    self.storeTest(timestamp: unixTime, fileType: fileType)
                    completed?(errorMessage)
                }
            }
            else {
                salesforceRequest { responseMessage in
                    if responseMessage == "success" {
                        BFLog("Salesforce request successful")
                        
                        do {
                            try FileManager.default.removeItem(at: mediaFilePath)
                        }
                        catch {
                            print("Unable to remove mediaFilePath = \(error.localizedDescription)")
                        }
                        
                        if self.id != nil {
                            self.remove()
                        }
                        completed?(responseMessage)
                    }
                    else {
                        BFLog("Unable to send request: \(responseMessage)")
                        
                        self.storeTest(timestamp: unixTime, fileType: fileType)
                        completed?(responseMessage)
                    }
                }
            }
        }
        else {
            // Encode the image
            if let image = UIImage(contentsOfFile: mediaFilePath.path),
                let imageData = image.jpegData(compressionQuality: 0.9) {
                self.encodedImage = imageData.base64EncodedString()
            }
            
            salesforceRequest { responseMessage in
                if responseMessage == "success" {
                    BFLog("Salesforce request successful")
                    
                    do {
                        try FileManager.default.removeItem(at: mediaFilePath)
                    }
                    catch {
                        print("Unable to remove mediaFilePath = \(error.localizedDescription)")
                    }
                    
                    if self.id != nil {
                        self.remove()
                    }
                    
                    completed?(responseMessage)
                }
                else {
                    BFLog("Unable to send request: \(responseMessage)")
                    
                    self.storeTest(timestamp: unixTime, fileType: fileType)
                    completed?(responseMessage)
                }
            }
        }
    }
    
    private func storeTest(timestamp: String, fileType: String) {
        // Check if the test is already stored
        guard id == nil else {
            uploadFailureCount += 1
            return
        }
        
        // Relocate the image/video to long term storage
        var fileUrl = getDocsPathURL().appendingPathComponent("uploadpending")
        
        if !FileManager.default.fileExists(atPath: fileUrl.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: fileUrl, withIntermediateDirectories: false, attributes: nil)
                print("created directory")
            }
            catch {
                print("Unable to create directory = \(error.localizedDescription)")
            }
        }
        
        let fileName = "\(timestamp)\(fileType)"
        fileUrl.appendPathComponent(fileName)
        
        let oldPath = URL(fileURLWithPath: self.mediaPath)
        
        do {
            try FileManager.default.moveItem(at: oldPath, to: fileUrl)
        }
        catch {
            print("Unable to move files = \(error.localizedDescription)")
        }
        
        self.mediaPath = fileName
        self.commit()
    }
    
    private func salesforceRequest(completed: @escaping (_ message: String) -> Void) {
        let urlExtension = isFacialRecogEnabled ? "BactrackResult2" : "BactrackResult"
        
        var request = URLRequest(url: URL(string: programUrl + urlExtension)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(partId, forHTTPHeaderField: "participant_id")
        request.addValue(partPin, forHTTPHeaderField: "pin")
        request.addValue(gpsLat, forHTTPHeaderField: "gps_lat")
        request.addValue(gpsLong, forHTTPHeaderField: "gps_long")
        request.addValue(bracLevel, forHTTPHeaderField: "brac_level")
        request.addValue(bracResult, forHTTPHeaderField: "brac_result")
        request.addValue(submitted, forHTTPHeaderField: "submitted")
        
        if let pic = imageUrl {
            BFLog("Uploading with aws image")
            
            request.addValue(pic, forHTTPHeaderField: "image_url")
        }
        else {
            BFLog("AWS image not provided")
        }
        
        if let vid = videoUrl {
            BFLog("Uploading with video")
            
            request.addValue(vid, forHTTPHeaderField: "video_url")
        }
        else {
            BFLog("Video not provided")
        }
        
        if let encodedPic = encodedImage {
            BFLog("Uploading with encoded pic")
            
            let body = "{ \"All_Images\":\"<Images><Picture>" + encodedPic + "</Picture></Images>\"}"
            request.httpBody = body.data(using: String.Encoding.utf8)
        }
        else if isVideo {
            BFLog("Adding blank xml package")
            
            let body = "{ \"All_Images\":\"<Images><Picture></Picture></Images>\"}"
            request.httpBody = body.data(using: String.Encoding.utf8)
        }
        else {
            BFLog("Encoded pic not provided")
        }
        
        Alamofire.request(request).responseString { response in
            switch (response.result) {
            case .success:
                if let responseStr = response.result.value {
                    let cleanedResponse = StringUtil.unescapeString(responseStr)
                    completed(cleanedResponse)
                }
                else {
                    completed("An unknown error occurred while uploading BAC test.")
                }
                
            case .failure(let error):
                completed(error.localizedDescription)
            }
        }
    }
    
    private func getDocsPathURL() -> URL {
        let fileName = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: fileName)
    }
}
