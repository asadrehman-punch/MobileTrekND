//
//  SurveyTextCell.swift
//  MobileTrek
//
//  Created by Asad Rehman khan on 29/08/2019.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit

class SurveyTextCell: UITableViewCell {

    @IBOutlet weak var otherTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
