//
//  SurveyTestOneViewController.swift
//  MobileTrek
//
//  Created by E Apple on 7/16/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
class SurveyTestOneViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var questionDesc: UILabel!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    var formName = ""
    var numberOfItems : Int = 0
    var index = 0
    var sectionArry = [Section]()
    var currentSection = Section()
    var surveyArr = [Survey]()
    var currentSurvey = Survey()
    var progressHud: MBProgressHUD? = nil
    var selectedIndex : Int = -1
    var selectedQuestion : Int = 0
    var selectedSection: Int = 0
    var isOtherSelected: Bool = false
    //    var selectedIndex = -1
    //    var select
    
    @IBOutlet weak var nextButtonView: UIView!
    
    @IBOutlet weak var backButtonView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.formName
        //        self.navigationItem.backBarButtonItem?.title = "hello"
        QuestionLabel.text = "Question 1:"
        QuestionLabel.isHidden = true
        answerLabel.isHidden = true
        questionDesc.isHidden = true
        self.indexLabel.isHidden = false
        self.saveButton.isHidden = true
        self.indexLabel.isHidden = true
        self.nextButtonView.isHidden = true
        self.backButtonView.isHidden = true
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
        //        numberOfItems = 5
        adjustTableViewHeight()
        sendRequest()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        saveButton.layer.cornerRadius = saveButton.frame.height / 5
        
    }
    
    func adjustTableViewHeight(){
        let tableViewHeight:CGFloat = 60.0
        
        
        
        //tableViewHeightConstraint.constant = tableViewHeight * CGFloat(numberOfItems)
    }
    func sendRequest(){
        progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        NTSurveyTest().sendSurveyRequest(formName: formName) { (data) in
            if (data?.first?.sectionName != ""){
                DispatchQueue.main.async {
                    self.selectedSection = 0
                    self.sectionArry = data!
                    //self.surveyArr = data!
                    for sectionz in self.sectionArry {
                        for surv in sectionz.survey{
                            self.surveyArr.append(surv)
                        }
                    }
                    //                    for item in self.surveyArr{
                    //                        if item.question_type == "Pick List With Other"{
                    //                            print(item)
                    //                        }
                    //                    }
                    self.currentSection = self.sectionArry.first!
                    // self.surveyArr = self.currentSection.survey
                    self.currentSurvey = self.surveyArr.first!
                    if (self.currentSurvey.question_type == "Pick list") || (self.currentSurvey.question_type == "Pick List With Other"){
                        self.numberOfItems = self.currentSurvey.options.count
                    }else if (self.currentSurvey.question_type == "Slider" || self.currentSurvey.question_type == "Text"){
                        
                        self.numberOfItems = 1
                    }
                    self.questionDesc.text = self.currentSurvey.question
                    self.adjustTableViewHeight()
                    if self.surveyArr.count >= 10{
                        self.indexLabel.text = "1/\(self.surveyArr.count)"
                    }
                    else{
                        self.indexLabel.text = "1/\(self.surveyArr.count)"
                    }
                    self.QuestionLabel.isHidden = false
                    self.answerLabel.isHidden = false
                    self.questionDesc.isHidden = false
                    self.indexLabel.isHidden = false
                    self.nextButtonView.isHidden = false
                    self.backButtonView.isHidden = false
                    
                    self.tableView.reloadData()
                    self.headerLabel.text = self.currentSection.sectionDescription
                    self.progressHud?.hide(animated: true)
                    
                }
                
            }
            else{
                self.progressHud?.hide(animated: true)
                print("Something went wrong...")
            }
            //print(data)
        }
        
        
    }
    func setHeaderLabel(){
        //        let item = sectionArry.filter{$0.survey == currentSurvey}
        //        self.headerLabel.text = item.first?.sectionName
        self.headerLabel.text = currentSurvey.sectionDescr
        //        for item in sectionArry{
        //            for ie in item.survey{
        //                if ie == currentSurvey{
        //                    ie.sectionDescr
        //                    self.headerLabel.text = item.sectionDescription//item.sectionName
        //
        //                }
        //            }
        //        }
    }
    
    
    
    @IBAction func backwardTapped(_ sender: Any) {
        //check which section we are in.
        
        
        if selectedQuestion != 0{
            self.indexLabel.isHidden = false
            self.saveButton.isHidden = true
            selectedQuestion = selectedQuestion - 1
            QuestionLabel.text = "Question \(selectedQuestion + 1):"
            currentSurvey = surveyArr[selectedQuestion]
            
            setHeaderLabel()
            //            for item in currentSurvey.options{
            //                if currentSurvey.selectedOp{
            //                    return
            //                }
            //            }
            self.questionDesc.text = self.currentSurvey.question
            
            if surveyArr.count >= 10{
                self.indexLabel.text = "\(selectedQuestion+1)/\(surveyArr.count)"
            }
            else{
                self.indexLabel.text = "\(selectedQuestion+1)/\(surveyArr.count)"
            }
            if currentSurvey.selectedOption != nil{
                if currentSurvey.question_type == "Pick List With Other" {
                    if !(currentSurvey.options.contains(currentSurvey.selectedOption)){
                        isOtherSelected = true
                    }else if currentSurvey.selectedOption == "Other" || currentSurvey.selectedOption == "other"{
                        isOtherSelected = true
                    }
                    else{
                        isOtherSelected = false
                    }
                }else {
                    isOtherSelected = false
                }
            }
            else{
                isOtherSelected = false
            }
            
            if (currentSurvey.question_type == "Pick list") || (currentSurvey.question_type == "Pick List With Other"){
                
                self.numberOfItems = self.currentSurvey.options.count
                
                
            }else if (currentSurvey.question_type == "Slider" || currentSurvey.question_type == "Text"){
                
                self.numberOfItems = 1
            }
            self.adjustTableViewHeight()
            self.view.layoutIfNeeded()
            tableView.reloadData()
            
        }
        else{
            
        }
    }
    @IBAction func forwardTapped(_ sender: Any) {
        
        let index = selectedQuestion + 1
        if index < surveyArr.count{
            self.indexLabel.isHidden = false
            self.saveButton.isHidden = true
            selectedQuestion = index
            QuestionLabel.text = "Question \(selectedQuestion + 1):"
            currentSurvey = surveyArr[selectedQuestion]
            setHeaderLabel()
            //  numberOfItems = self.currentSurvey.options.count
            if (currentSurvey.question_type == "Pick list") || (currentSurvey.question_type == "Pick List With Other"){
                self.numberOfItems = self.currentSurvey.options.count
            }else if (currentSurvey.question_type == "Slider" || currentSurvey.question_type == "Text"){
                
                self.numberOfItems = 1
            }
            self.adjustTableViewHeight()
            self.view.layoutIfNeeded()
            questionDesc.text = self.currentSurvey.question
            if surveyArr.count >= 10{
                self.indexLabel.text = "\(selectedQuestion+1)/\(surveyArr.count)"
                
            }
            else{
                self.indexLabel.text = "\(selectedQuestion+1)/\(surveyArr.count)"
            }
            if currentSurvey.selectedOption != nil{
                if currentSurvey.question_type == "Pick List With Other" {
                    if !(currentSurvey.options.contains(currentSurvey.selectedOption)){
                        isOtherSelected = true
                    }else if currentSurvey.selectedOption == "Other" || currentSurvey.selectedOption == "other"{
                        isOtherSelected = true
                    }
                    else{
                        isOtherSelected = false
                    }
                }else {
                    isOtherSelected = false
                }
            }
            else{
                isOtherSelected = false
            }
            if (currentSurvey.question_type == "Pick list") || (currentSurvey.question_type == "Pick List With Other"){
                
                self.numberOfItems = self.currentSurvey.options.count
                
                
            }else if (currentSurvey.question_type == "Slider" || currentSurvey.question_type == "Text"){
                
                self.numberOfItems = 1
            }
            self.adjustTableViewHeight()
            self.view.layoutIfNeeded()
            tableView.reloadData()
            tableView.reloadData()
            
        }else{
            self.indexLabel.isHidden = true
            self.saveButton.isHidden = false
        }
        
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        print(self.surveyArr)
        progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        var parameters = [Parameters]()
        for suv in self.surveyArr {
            print(suv.getParameters())
            parameters.append(suv.getParameters())
        }
        
        NTSurveyTest().sendSurveyRequestForm(surveyResult: parameters,formName:self.formName) { (status, message) in
            
            if status{
                self.progressHud?.hide(animated: true)
                let alert = UIAlertController(title: "MobileTrek", message:"Results Submitted Successfully", preferredStyle: .alert)
                
                let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                })
                
                
                
                alert.addAction(doneAction)
                self.present(alert, animated: true, completion: nil)
                
            }else{
                self.progressHud?.hide(animated: true)
                print("Something went wrong...")
                let alert = UIAlertController(title: "MobileTrek", message:"An error occurred", preferredStyle: .alert)
                
                let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                })
                
                
                
                alert.addAction(doneAction)
                self.present(alert, animated: true, completion: nil)
            }
            print(message)
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension SurveyTestOneViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isOtherSelected){
            return numberOfItems + 1;
        }
        return numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if currentSurvey.question_type == "Pick list"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SurveyTestOneTableViewCell
            cell.titleLabel.text = currentSurvey.options[indexPath.row]//"Hello world"
            print(currentSurvey.selectedOption)
            if currentSurvey.selectedOption != nil {
                if currentSurvey.selectedOption == currentSurvey.options[indexPath.row] {
                    cell.selectedIcon.image = UIImage(named: "checked")
                }else{
                    cell.selectedIcon.image = UIImage(named: "unchecked")
                    
                    
                }
            }else{
                cell.selectedIcon.image = UIImage(named: "unchecked")
            }
            
            return cell
        }else if currentSurvey.question_type == "Slider"{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SurveySliderCell", for: indexPath) as! SurveySliderCell
            if (self.currentSurvey.selectedOption != nil){
                cell.slider.value = Float(self.currentSurvey.selectedOption)!
            }else{
                cell.slider.value = 0.5
            }
            cell.slider.addTarget(self, action:#selector(SurveyTestOneViewController.sliderValueChanged(sender:)), for: .valueChanged)
            return cell
            
        }else if currentSurvey.question_type == "Text"{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyTextCell", for: indexPath) as! SurveyTextCell
            cell.textView.delegate = self
            if (self.currentSurvey.selectedOption != nil){
                cell.textView.text = self.currentSurvey.selectedOption
            }else{
                cell.textView.text = ""
            }
            return cell
            
        }
        else if currentSurvey.question_type == "Pick List With Other"{
            
            
            
            print(indexPath.row)
            print(numberOfItems)
            if indexPath.row == numberOfItems{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyTextFieldCell", for: indexPath) as! SurveyTextCell
                var selOption = currentSurvey.selectedOption
                if currentSurvey.selectedOption == "Other" || currentSurvey.selectedOption == "other"{
                    selOption = ""
                }
                cell.otherTextField.text = selOption
                cell.otherTextField.delegate = self
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SurveyTestOneTableViewCell
                
                
                print(currentSurvey.selectedOption)
                if (isOtherSelected){
                    if indexPath.row == numberOfItems - 1{
                        cell.selectedIcon.image = UIImage(named: "checked")
                    }
                    else{
                        cell.selectedIcon.image = UIImage(named: "unchecked")
                    }
                }
                else{
                    if currentSurvey.selectedOption != nil {
                        if currentSurvey.selectedOption == currentSurvey.options[indexPath.row] {
                            cell.selectedIcon.image = UIImage(named: "checked")
                        }else{
                            cell.selectedIcon.image = UIImage(named: "unchecked")
                        }
                    }else{
                        cell.selectedIcon.image = UIImage(named: "unchecked")
                    }
                }
                cell.titleLabel.text = currentSurvey.options[indexPath.row]
                
                return cell
            }
            
        }
        let cell = UITableViewCell(frame: CGRect.zero)
        return cell
    }
    func scrollToBottom(index: Int){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if currentSurvey.question_type == "Text"{
            return 90.0
        }
        return 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
        if currentSurvey.question_type == "Slider" || currentSurvey.question_type == "Text" {
            return
        }
        else if (currentSurvey.question_type == "Pick List With Other") {
            
            if  !currentSurvey.options.canSupport(index: indexPath.row){
                return
            }
            if ((currentSurvey.options[indexPath.row] == "Other") || (currentSurvey.options[indexPath.row] == "other")){
                
                selectedIndex = indexPath.row
                isOtherSelected = true
                let selectedOption = currentSurvey.options[indexPath.row]
                if selectedOption == currentSurvey.selectedOption{
                    currentSurvey.selectedOption = nil
                    isOtherSelected = false
                    tableView.reloadData()
                }else{
                    
                    currentSurvey.selectedOption = selectedOption
                    tableView.reloadData()
                    scrollToBottom(index: currentSurvey.options.count)
                }
            }else{
                isOtherSelected = false
                let selectedOption = currentSurvey.options[indexPath.row]
                if selectedOption == currentSurvey.selectedOption{
                    currentSurvey.selectedOption = nil
                }else{
                    currentSurvey.selectedOption = selectedOption
                }
                tableView.reloadData()
            }
            
            return
            
        }else if currentSurvey.question_type == "Pick list" {
            isOtherSelected = false
            let selectedOption = currentSurvey.options[indexPath.row]
            if selectedOption == currentSurvey.selectedOption{
                currentSurvey.selectedOption = nil
            }else{
                currentSurvey.selectedOption = selectedOption
            }
            tableView.reloadData()
        }
        
    }
    
    @objc func sliderValueChanged(sender: UISlider){
        let currentValue = sender.value
        self.currentSurvey.selectedOption = "\(currentValue)"
        print("\(currentValue)")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        print(textField.text!)
    }
    
    
}


extension SurveyTestOneViewController: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        let currentValue = textView.text!
        self.currentSurvey.selectedOption = currentValue
    }
}
extension SurveyTestOneViewController : UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            self.currentSurvey.selectedOption = self.currentSurvey.options.last!
            return
        }
        self.currentSurvey.selectedOption = textField.text ?? ""
    }
}
