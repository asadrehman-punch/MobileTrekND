//
//  FeedbackViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 10/31/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD

class FeedbackViewController: UITableViewController {
	
	@IBOutlet weak var programIdField: UITextField!
    @IBOutlet weak var partIdField: UITextField!
	@IBOutlet weak var feedbackField: UITextView!
    
    fileprivate let kFeedbackPlaceholder: String = "Enter suggestion or feedback"
	fileprivate let placeHolderColor = UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate var sendButton: UIBarButtonItem!
	fileprivate var progressHud: MBProgressHUD?
    
    var isFromLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        programIdField.delegate = self
        partIdField.delegate = self
        feedbackField.delegate = self
        
        doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButton_Clicked))
        sendButton = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButton_Clicked))
        
        self.navigationItem.rightBarButtonItem = sendButton
    }
	
	// MARK: - Selectors
	
    @objc func doneButton_Clicked() {
        self.view.endEditing(true)
    }
    
	@objc func sendButton_Clicked() {
		progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
		progressHud?.label.text = "Loading..."
		
        if let errorMsg = validationMessage() {
			DispatchQueue.main.async {
				self.progressHud?.hide(animated: true)
			}
			
            showStandardAlert(title: "Feedback Error", message: errorMsg)
        }
        else {
			NTFeedbackRequest().sendRequest(programId: programIdField.text!, participantId: partIdField.text!, feedback: feedbackField.text, { success, message in
				DispatchQueue.main.async {
					self.progressHud?.hide(animated: true)
				}
				
				if success {
					self.showStandardAlert(title: "Feedback Sent", message: "Your feedback was sent successfully, thank you!", {
						let sb = UIStoryboard(name: "Main", bundle: nil)
						
                        if self.isFromLogin {
                            let loginVC = sb.instantiateViewController(withIdentifier: "loginViewController")
                            self.navigationController?.pushViewController(loginVC, animated: true)
                        }
                        else {
                          //  let mtrekmenu = sb.instantiateViewController(withIdentifier: "mtrekmenu") as! MTrekMenuViewController
                            //mtrekmenu.isFromSupport = true
                            self.navigationController?.popToViewController((self.navigationController?.viewControllers[2])!, animated: true)
                            //self.navigationController?.pushViewController(mtrekmenu, animated: true)
                        }
					})
				}
				else {
					self.showStandardAlert(title: "Feedback Error", message: message)
				}
			})
        }
	}
    
    // MARK: - Class Functions
    
    private func validationMessage() -> String? {
        let programId = (programIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let partId = (partIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let feedback = feedbackField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if programId.isEmpty {
            return "Program ID Field is required."
        }
        
        if partId.isEmpty {
            return "Participant ID Field is required."
        }
        
        if feedback.isEmpty || feedback == kFeedbackPlaceholder {
            return "Feedback field is required."
        }
        
        return nil
    }
    
    private func showStandardAlert(title: String, message: String, _ closure: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            closure?()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension FeedbackViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.navigationItem.rightBarButtonItem = sendButton
    }
}

// MARK: - UITextViewDelegate

extension FeedbackViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem = doneButton
        
        if (textView.text == kFeedbackPlaceholder) {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem = sendButton
        
        if (textView.text == "") {
            textView.text = kFeedbackPlaceholder
            textView.textColor = placeHolderColor
        }
        textView.resignFirstResponder()
    }
}
