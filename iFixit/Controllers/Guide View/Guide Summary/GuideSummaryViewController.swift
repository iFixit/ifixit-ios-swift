//
//  GuideSummaryViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/2/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideSummaryViewController: UIViewController {
    
    var guide: Guide?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let guide = guide {
            print(guide.title)
        } else {
            print("No Guide Loaded")
        }
    }
}

extension GuideSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideSummaryImageCell", for: indexPath) as! GuideSummaryImageTableViewCell
            
            cell.summaryImage?.downloaded(from: guide?.image?.large ?? "")
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideSummaryTitleCell", for: indexPath) as! GuideSummaryTitleTableViewCell
            let title = guide?.title
            let author = guide?.author.username
            let summary = guide?.summary
            
            cell.guideTitle.text = title
            cell.guideAuthor.text = "by \(author ?? "Some Person")"
            cell.authorAvatar.downloaded(from: guide?.author.image?.thumbnail ?? "")
            cell.summary.text = summary == "" || summary == nil ? "This guide has no summary" : summary
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideInfoCell", for: indexPath) as! GuideInfoTableViewCell
            
            let stepCount = guide?.steps.count
            
            cell.stepCount.text = "\(stepCount ?? 0) steps"
            
            return cell
        }
    }
}
