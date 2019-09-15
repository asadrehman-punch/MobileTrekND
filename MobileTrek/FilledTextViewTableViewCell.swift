//
//  FilledTextViewTableViewCell.swift
//  MobileTrek
//
//  Created by E Apple on 8/31/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit

class FilledTextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
