//
//  GuideEditSummaryInfoTableViewCell.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/5/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideEditSummaryInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var guideTitle: UITextField!
    @IBOutlet weak var guideSummary: UITextField!
    @IBOutlet weak var publicToggle: UISwitch!
    
    var parentVC: GuideEditSummaryViewController?
    
    @IBAction func publicToggled(_ sender: UISwitch) {
        self.parentVC?.updateGuide()
    }
}
