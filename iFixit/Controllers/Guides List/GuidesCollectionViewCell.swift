//
//  GuidesCollectionViewCell.swift
//  iFixit
//
//  Created by Tanner Villarete on 2/8/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuidesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var guideImage: UIImageView!
    @IBOutlet weak var guideTitle: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
        self.fadeIn()
            
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }

}
