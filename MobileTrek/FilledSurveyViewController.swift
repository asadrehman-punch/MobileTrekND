//
//  FilledSurveyViewController.swift
//  MobileTrek
//
//  Created by Asad Rehman khan on 29/08/2019.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
class FilledSurveyViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
  
    
    @IBOutlet weak var tableView: UITableView!
    var currentSurvey: SurveyTest!
    var progressHud: MBProgressHUD? = nil
    var questions = [Question]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.title = self.currentSurvey.form_name
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.sendRequest()
    }
    
    
    func sendRequest(){
        progressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        NTSurveyTest().sendHistorySurveyRequest(formID: self.currentSurvey.form_id) { (data) in
            if (data!.count > 0){
                
                    self.questions = data!
                    self.tableView.reloadData()
                    self.progressHud?.hide(animated: true)
                    
                }else{
                self.progressHud?.hide(animated: true)
                print("Something went wrong...")
            }
            //print(data)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let que = self.questions[indexPath.row]
        
        if que.question_type == "Text" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textView", for: indexPath) as! FilledTextViewTableViewCell
            cell.questionLabel.text = "Question: \(que.question)"
            var option = que.selected_option
            if option == ""{
                option = ""
            }
            cell.textView.text = option
            cell.selectionStyle = .none
            return cell
            /* let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyTextCell", for: indexPath) as! SurveyTextCell
             print(que.selected_option)
             cell.textView.text = que.selected_option
             return cell*/
            
        }else if que.question_type == "Slider" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "slider", for: indexPath) as! FilledSliderTableViewCell
            cell.questionLabel.text = "Question: \(que.question)"
            if (que.selected_option as NSString).floatValue > 0 {
                cell.slider.value = (que.selected_option as NSString).floatValue * 10
            }else {
                cell.slider.value = 0
            }
            cell.selectionStyle = .none
            return cell
            /*let cell = tableView.dequeueReusableCell(withIdentifier: "SurveySliderCell", for: indexPath) as! SurveySliderCell
             if (que.selected_option as NSString).floatValue > 0 {
             cell.slider.value = (que.selected_option as NSString).floatValue
             }else {
             cell.slider.value = 50
             }
             
             return cell*/
        }else if que.question_type == "Pick list"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "option", for: indexPath) as! FilledOptionTableViewCell
            cell.questionLabel.text = "Question: \(que.question)"
            var option = que.selected_option
            if option == ""{
                option = "N/A"
            }
            cell.optionLabel.text = option
            cell.selectionStyle = .none
            return cell
            /*let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyTextCell", for: indexPath) as! SurveyTextCell
             print(que.selected_option)
             cell.textView.text = que.selected_option*/
        }else if que.question_type == "Pick List With Other"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "textView", for: indexPath) as! FilledTextViewTableViewCell
            //print(que.selected_option)
            cell.questionLabel.text = "Question: \(que.question)"
            cell.textView.text = que.selected_option
            cell.selectionStyle = .none
            return cell
        }
        let cell = UITableViewCell()
        return cell
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

