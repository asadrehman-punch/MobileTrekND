//
//  NTSurveyTest.swift
//  MobileTrek
//
//  Created by E Apple on 7/17/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NTSurveyTest: NSObject {
    
    
    private let surveyTestUrl: String = "https://demo-0001.secure.force.com/services/apexrest/FormsForUser"
    private let surveyUrl: String = "https://demo-0001.secure.force.com/services/apexrest/SurveryFormForUser"
    private let submitResult: String = "https://demo-0001.secure.force.com/services/apexrest/SurveryResponse"
    private let historyResult: String = "https://demo-0001.secure.force.com/services/apexrest/FilledFormDetails"
    //    private let accessKey: String = "MAAK201700003"
    
    func sendSurveyTestRequest(_ closure: @escaping (_ latestVersion: [SurveyTest]?) -> Void) {
        /*if let programId = defaults.string(forKey: "globalProgramId") {
         programField.text = programId
         }
         
         if let pin = defaults.string(forKey: "globalPin") {
         pinField.text = pin
         }*/
        let headers: [String:String] = [
            "Content-Type": "application/json",
            "participant_id": UserDefaults.standard.string(forKey: "globalPartId")!,
            "pin":UserDefaults.standard.string(forKey: "globalPin")!
        ]
        
        let params: [String: String] = [
            "participant_id": UserDefaults.standard.string(forKey: "globalPartId")!,
            "pin":UserDefaults.standard.string(forKey: "globalPin")!]
        
        Alamofire.request(surveyTestUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    let statusCode = json["statusCode"].int!
                    if statusCode == 200{
                        let forms = json["forms"].array
                        let hForms = json["filledForms"].array
                        var data = [SurveyTest]()
                        for item in forms!{
                            let surveyData = SurveyTest()
                            surveyData.form_id = item["form_id"].string!
                            surveyData.form_name = item["form_name"].string!
                            surveyData.isFilled = false
                            data.append(surveyData)
                            
                        }
                        
                        if hForms != nil {
                            for item in hForms!{
                                let surveyData = SurveyTest()
                                surveyData.form_id = item["form_id"].string!
                                if item["form_name"].string  != nil{
                                    surveyData.form_name = item["form_name"].string!
                                }else{
                                    surveyData.form_name = "Form"
                                }
                                surveyData.created_date = item["created_date"].string!
                                surveyData.isFilled = true
                                data.append(surveyData)
                            
                            }
                        }
                        closure(data)
                    }
                    else{
                        closure([SurveyTest]())
                    }
                    
                    
                case .failure:
                    closure([SurveyTest]())
                }
        }
    }
    
    
    func sendSurveyRequestForm(surveyResult: [Parameters],formName: String,
                               _ closure: @escaping (_ success: Bool, _ message: String) -> Void) {
        let headers: [String:String] = [
            "Content-Type": "application/json",
            "participant_id": UserDefaults.standard.string(forKey: "globalPartId")!,
            "pin":UserDefaults.standard.string(forKey: "globalPin")!,
            "form_name": formName
        ]
        
        let params: Parameters = [
            "questions": surveyResult
        ]
        
        Alamofire.request(submitResult, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    
                    if let message = json["message"].string {
                        closure(message == "success", message)
                    }
                    else {
                        print("json = \(json)")
                        closure(false, "An unknown error has occurred while trying to send feedback.")
                    }
                    
                case .failure(let error):
                    closure(false, error.localizedDescription)
                }
        }
    }
    
    
    func sendSurveyRequest(formName: String,_ closure: @escaping (_ latestVersion: [Section]?) -> Void) {
        /*if let programId = defaults.string(forKey: "globalProgramId") {
         programField.text = programId
         }
         
         if let pin = defaults.string(forKey: "globalPin") {
         pinField.text = pin
         }*/
        let headers: [String:String] = [
            "Content-Type": "application/json",
            "participant_id": UserDefaults.standard.string(forKey: "globalPartId")!,
            "pin":UserDefaults.standard.string(forKey: "globalPin")!,
            "form_name": formName
        ]
        
        let params: [String: String] = [
            "participant_id": UserDefaults.standard.string(forKey: "globalPartId")!,
            "pin":UserDefaults.standard.string(forKey: "globalPin")!,
            "form_name": formName]
        
        Alamofire.request(surveyUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    let statusCode = json["statusCode"].int!
                    if statusCode == 200{
                        let sections = json["sections"].array
                        
                        var userSections = [Section]()
                        for section in sections!{
                            var dataSection = Section()
                            dataSection.sectionID = section["sectionID"].string!
                            dataSection.sectionName = section["sectionName"].string!
                            if section["sectionDescription"].string != nil {
                                dataSection.sectionDescription = section["sectionDescription"].string!
                            }
                            if section["sectionOrder"].string != nil{
                                dataSection.sectionOrder = section["sectionOrder"].string!
                            }else{
                                dataSection.sectionOrder = "0"
                            }
                            let forms = section["questions"].array
                            var data = [Survey]()
                            for item in forms!{
                                let surveyData = Survey()
                                surveyData.question_type = item["question_type"].string!
                                surveyData.question_id = item["question_id"].string!
                                surveyData.question = item["question"].string!
                                surveyData.sectionOr = dataSection.sectionOrder
                                surveyData.sectionDescr = dataSection.sectionDescription
                                if (surveyData.question_type == "Pick list" || surveyData.question_type == "Pick List With Other"){
                                    let options = item["options"].array!
                                    var rOptions = [String]()
                                    for option in options{
                                        let opt = option.string!
                                        rOptions.append(opt)
                                        
                                    }
                                    surveyData.options = rOptions
                                }
                                
                                data.append(surveyData)
                            }
                            dataSection.survey = data
                            userSections.append(dataSection)
                        }
                        closure(userSections)
                    }
                    else{
                        closure([Section]())
                    }
                    
                    
                case .failure:
                    closure([Section]())
                }
        }
    }
    
    func sendHistorySurveyRequest(formID: String,_ closure: @escaping (_ latestVersion: [Question]?) -> Void) {
        /*if let programId = defaults.string(forKey: "globalProgramId") {
         programField.text = programId
         }
         
         if let pin = defaults.string(forKey: "globalPin") {
         pinField.text = pin
         }*/
        let headers: [String:String] = [
            "Content-Type": "application/json",
            "participant_id": UserDefaults.standard.string(forKey: "globalPartId")!,
            "pin":UserDefaults.standard.string(forKey: "globalPin")!,
            "form_id": formID
        ]
        
        let params: [String: String] = [
            "participant_id": UserDefaults.standard.string(forKey: "globalPartId")!,
            "pin":UserDefaults.standard.string(forKey: "globalPin")!,
            "form_id": formID]
        
        Alamofire.request(historyResult, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    let statusCode = json["statusCode"].int!
                    if statusCode == 200{
                        let questions = json["questions"].array
                        var quz = [Question]()
                        for question in questions! {
                            let ques = Question()
                            ques.question = question["question"].string!
                            //ques.question_id = question[""]
                            if (question["question_type"].string != nil){
                                ques.question_type = question["question_type"].string!
                            }else{
                                ques.question_type = ""
                            }
                            if (question["question_type"].string != nil){
                                ques.selected_option = question["selected_option"].string ?? ""
                            }else{
                                ques.selected_option = ""
                            }
                            quz.append(ques)
                            
                        }
                        
                        
                        closure(quz)
                    }
                    else{
                        closure([Question]())
                    }
                    
                    
                case .failure:
                    closure([Question]())
                }
        }
    }
}

