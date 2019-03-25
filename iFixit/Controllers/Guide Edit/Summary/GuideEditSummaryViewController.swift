//
//  GuideEditSummaryViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/3/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideEditSummaryViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var viewIndex: Int?
    var guide: Guide?
    var user: User?
    var parentVC: GuideEditPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentVC = super.parent as? GuideEditPageViewController
        
        if let _ = guide {
            tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    public func updateGuide() {
        let mediaIndexPath = IndexPath(row: 0, section: 0)
        let infoIndexPath = IndexPath(row: 1, section: 0)
        let infoCell = tableView.cellForRow(at: infoIndexPath) as! GuideEditSummaryInfoTableViewCell
        let mediaCell = tableView.cellForRow(at: mediaIndexPath) as! GuideEditSummaryMediaTableViewCell
        
        if (mediaCell.imageData != nil) {
            guide?.image = mediaCell.imageData
        }
        guide?.title = infoCell.guideTitle.text!
        guide?.summary = infoCell.guideSummary.text!
        guide?.public = infoCell.publicToggle.isOn
        parentVC?.guide = guide!
        parentVC?.hasEditedGuide = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateGuide()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mediaVC = segue.destination as? MediaManagerViewController {
            mediaVC.user = self.user

            print("Set mediaVC User")
        } else {
            print("Never prepared for segue")
        }
    }
    
    @IBAction func unwindToGuideEditSummary(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MediaManagerViewController, let selectedMediaImage = sourceViewController.selectedImage {
            self.guide?.image = selectedMediaImage.image
            DispatchQueue.main.async {
                self.parentVC?.hasEditedGuide = true
                self.parentVC?.guide?.image = selectedMediaImage.image
                self.tableView.reloadData()
            }
        } else if let _ = sender.source as? GuideViewController {
            print("Unwound to guide list from Guide View")
        }
    }
}

extension GuideEditSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideEditMediaCell", for: indexPath) as! GuideEditSummaryMediaTableViewCell
            
            if let guide = guide, guide.image != nil {
                cell.summaryImage.downloaded(from: guide.image?.standard ?? "")
                cell.imageData = guide.image
                cell.summaryImage.isHidden = false
                cell.addImageStack.isHidden = true
                cell.summaryImage.tintColor = .darkGray
            } else {
                print("HERE")
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideEditInfoCell", for: indexPath) as! GuideEditSummaryInfoTableViewCell
            
            if let guide = guide {
                cell.guideTitle.delegate = self
                cell.guideSummary.delegate = self
                cell.guideTitle.text = guide.title
                cell.guideSummary.text = guide.summary
                cell.publicToggle.isOn = guide.public
                cell.parentVC = self
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
