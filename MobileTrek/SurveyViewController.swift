//
//  SurveyViewController.swift
//  MobileTrek
//
//  Created by E Apple on 7/16/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD

class SurveyViewController: UIViewController {
    
    @IBOutlet weak var sideMenu: SideMenuController!
    @IBOutlet weak var tableView: UITableView!
    var surveyArr = [SurveyTest]()
    var progressHud: MBProgressHUD? = nil
    var filledSurvey = [SurveyTest]()
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenu.delegate = self
        self.title = "Survey Test"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 50.0
        let nib = UINib(nibName: "FormHeaderCell", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "FormHeaderCell")
        self.tableView.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        setSelected()
        self.navigationItem.setHidesBackButton(true, animated: false)
        sendRequest()
        
    }
    func setSelected(){
        sideMenu.surveySelected()
    }
    func sendRequest(){
        self.surveyArr.removeAll()
        self.filledSurvey.removeAll()
        progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        NTSurveyTest().sendSurveyTestRequest { (data) in
            if (data?.first?.form_id != ""){
                DispatchQueue.main.async {
                    var response = [SurveyTest]()
                    response  = data!
                    for surv in response {
                        if surv.isFilled {
                            self.filledSurvey.append(surv)
                        }else{
                            self.surveyArr.append(surv)
                        }
                    }
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                    self.progressHud?.hide(animated: true)
                }
                
            }
            else{
                self.progressHud?.hide(animated: true)
                print("Something went wrong...")
            }
            
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
extension SurveyViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        
        // Dequeue with the reuse identifier
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "FormHeaderCell") as! FormHeaderCell
        
        if section == 0{
            header.titleLabel.text = "Available Surveys"
        }else{
            header.titleLabel.text = "Completed Surveys"
        }
        
        return header
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return surveyArr.count
        }else{
            return filledSurvey.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SurveyTableViewCell
        if (indexPath.section == 0){
            cell.titleLabel.text = surveyArr[indexPath.row].form_name//"Coffee Consumption"
            cell.dateLabel.isHidden = true
        }else if (indexPath.section == 1){
            cell.titleLabel.text = filledSurvey[indexPath.row].form_name//"Coffee Consumption"
            cell.dateLabel.text = "Created at \(filledSurvey[indexPath.row].created_date!)"
            cell.dateLabel.isHidden = false
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0){
            let dest = self.storyboard?.instantiateViewController(withIdentifier: "SurveyTestOneViewController") as! SurveyTestOneViewController
            dest.formName = surveyArr[indexPath.row].form_name
            self.navigationController?.pushViewController(dest, animated: false)
            
        }else if (indexPath.section == 1){
            let dest = self.storyboard?.instantiateViewController(withIdentifier: "FilledSurveyViewController") as! FilledSurveyViewController
            dest.currentSurvey = filledSurvey[indexPath.row]
            self.navigationController?.pushViewController(dest, animated: false)
        }
    }
    
    
}
extension SurveyViewController: SideMenuDelegate{
    func surveyTapped() {
        /*let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "SurveyViewController") as! SurveyViewController
         self.navigationController?.pushViewController(mtrekmenu, animated: false)*/
    }
    func testStatusTapped() {
        
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "testStatusDash") as! TestStatusDashboardViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
    }
    
    func mettingTapped() {
        // Do nothing as it is on the required page
        let mtrekmenu = self.storyboard?.instantiateViewController(withIdentifier: "checkInOutDash") as! CheckInOutDashboardViewController
        self.navigationController?.pushViewController(mtrekmenu, animated: false)
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
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController")
        self.navigationController?.pushViewController(loginVC!, animated: false)
    }
    
    
}
