//
//  GuideStepViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/2/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideStepViewController: UIViewController {
    
    var step: GuideStep?
    var stepNumber: Int?
    var attributes = [NSAttributedString.Key: Any]()
    let paragraphStyle = NSMutableParagraphStyle()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the bullet points using paragraph attributes.
        attributes[.font] = UIFont.preferredFont(forTextStyle: .body)
        attributes[.foregroundColor] = UIColor.darkGray
        
        let bullet = "•  "
        paragraphStyle.headIndent = (bullet).size(withAttributes: attributes).width
        attributes[.paragraphStyle] = paragraphStyle
    }
}

extension GuideStepViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (self.step?.lines.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideStepHeaderCell", for: indexPath) as! GuideStepHeaderTableViewCell
            
            let imageArray = self.step?.media?.data
            
            cell.setCollectionViewWith(imageArray: imageArray!)
            cell.stepNumber.text = "Step \(self.stepNumber ?? 0)"
            cell.pageControl.numberOfPages = (imageArray!.count)
            cell.parentView = self
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideStepCell", for: indexPath) as! GuideStepTableViewCell
            
            let stepText = self.step?.lines[indexPath.row - 1].text_raw
            
            cell.stepDetail.attributedText = NSAttributedString(string: "•  \(stepText ?? "No Text")", attributes: attributes)
            cell.isUserInteractionEnabled = false
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
