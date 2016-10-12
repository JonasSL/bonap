//
//  ChartCell.swift
//  Bonapp
//
//  Created by Jonas Larsen on 12/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import UIKit
import Charts

class ChartCell: UITableViewCell {

    @IBOutlet weak var pieChartView: PieChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
