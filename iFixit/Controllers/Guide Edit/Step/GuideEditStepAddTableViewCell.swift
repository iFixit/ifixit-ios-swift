//
//  GuideEditStepAddTableViewCell.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/18/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideEditStepAddTableViewCell: UITableViewCell {
    var parentView: GuideEditStepViewController?
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let line = GuideStep.GuideLine(bullet: "black", level: 0, text_raw: "")
        
        parentView?.addBullet(bullet: line)
    }
}
