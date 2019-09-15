//
//  SurveySliderCell.swift
//  MobileTrek
//
//  Created by Asad Rehman khan on 27/08/2019.
//  Copyright © 2019 RecoveryTrek. All rights reserved.
//

import UIKit

class SurveySliderCell: UITableViewCell {

    @IBOutlet weak var slider: UISlider!
    var currentValue: Float = 0.0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func slider(_ sender: Any) {
        
        currentValue = slider.value
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
