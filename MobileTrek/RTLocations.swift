//
//  RTLocations.swift
//  MobileTrek
//
//  Created by Steven Fisher on 7/14/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit
import Alamofire
class RTLocations: NSObject {
    var name: String!
    var address1: String!
    var address2: String!
    var city: String!
    var state: String!
    var zip: String!
    var message: String?
    var distance: Double?
    var phones: [String] = [String]()
}
class SurveyTest: NSObject {
    //    "form_id" = a271Y000001JNo1QAG;
    //    "form_name" = "Lifestyle Data";
    var form_id: String = ""
    var form_name: String = ""
    var isFilled = false
    var created_date: String!
    
}
class Survey: Equatable{
    static func == (lhs: Survey, rhs: Survey) -> Bool {
        if lhs.question_id == rhs.question_id{
            return true
        }
        return false
    }
    
    var question_type: String = ""
    var question_id: String = ""
    var question: String = ""
    var options: [String]!
    var selectedOption: String!
    var sectionDescr: String!
    var sectionOr: String!
    
    func getParameters() -> Parameters {
        var parameters = [String: String]()
        parameters["question_type"] = question_type
        parameters["question_id"] = question_id
        parameters["question"] = question
        if question_type == "Pick list" || question_type == "Pick List With Other" {
            parameters["selected_option"] = selectedOption != nil ? selectedOption : "--None--"
        }else if question_type == "Slider"{
            parameters["selected_option"] = selectedOption != nil ? selectedOption : "0.5"
        }else if question_type == "Text" {
            parameters["selected_option"] = selectedOption != nil ? selectedOption : ""
        }
        parameters["section_description"] = sectionDescr != nil ? sectionDescr : nil
        parameters["section_order"] = sectionOr
        return parameters
    }
    
    
}

class Section: Equatable {
    static func == (lhs: Section, rhs: Section) -> Bool {
        if lhs.sectionID == rhs.sectionID{
            return true
        }
        return false
    }
    
    var sectionName: String = ""
    var sectionID: String = ""
    var sectionDescription: String = ""
    var sectionOrder: String = ""
    var survey: [Survey]!
    
}

class Question: Codable {
    var question_type: String = ""
    var question_id: String = ""
    var question: String = ""
    var section_description: String = ""
    var section_order: String = ""
    var selected_option: String = ""
}
