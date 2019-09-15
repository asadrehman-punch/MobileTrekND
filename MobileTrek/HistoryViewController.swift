//
//  HistoryViewController.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/18/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	
	var data: [String] = [String]()
	var vcTitle: String = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 44
		
		self.navigationItem.title = vcTitle
	}
	
	// MARK: - UITableView Delegate
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! AutoSizingTableViewCell
		cell.label.text = data[indexPath.row];
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
