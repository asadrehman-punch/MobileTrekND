//
//  FilledSliderTableViewCell.swift
//  MobileTrek
//
//  Created by E Apple on 8/31/19.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit

class FilledSliderTableViewCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
