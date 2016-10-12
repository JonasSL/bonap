//
//  ReceiptCell.swift
//  Bonapp
//
//  Created by Jonas Larsen on 12/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import UIKit

class ReceiptCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
