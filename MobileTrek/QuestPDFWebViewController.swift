//
//  QuestPDFWebViewController.swift
//  MobileTrek
//
//  Created by Karthik Navuluri on 4/29/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit
import MessageUI

class QuestPDFWebViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @objc var encodedPDFData: String? = nil
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var email: UIBarButtonItem!
    
    @IBAction func emailClicked(_ sender: UIBarButtonItem) {
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Lab Authorization")
            mailComposer.setMessageBody("", isHTML: true)
            
            if let fileData = Data(base64Encoded: encodedPDFData!, options: .ignoreUnknownCharacters) {
                mailComposer.addAttachmentData(fileData, mimeType: "application/pdf", fileName: "QuestAuthorization.pdf")
            }
            
            
            self.present(mailComposer, animated: true, completion: nil)
            return
        }
    }
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        self.dismiss(animated: true, completion: nil)
        print("sent!")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let decodeData = Data(base64Encoded: encodedPDFData!, options: .ignoreUnknownCharacters) {
            webView.load(decodeData, mimeType: "application/pdf", textEncodingName: "utf-8", baseURL: URL(fileURLWithPath: ""))
        } // since you don't have url, only encoded String
    }
}

