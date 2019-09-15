//
//  SurveyTestOneTableViewCell.swift
//  MobileTrek
//
//  Created by E Apple on 7/16/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit

class SurveyTestOneTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
