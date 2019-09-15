//
//  ButtonTableViewCell.swift
//  MobileTrek
//
//  Created by Steven Fisher on 5/13/16.
//  Copyright © 2016 RecoveryTrek. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var noResultLabel: UILabel!
    
	@IBOutlet weak var titleLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
