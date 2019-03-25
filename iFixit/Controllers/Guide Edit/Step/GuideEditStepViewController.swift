//
//  GuideEditStepViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/3/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideEditStepViewController: UIViewController, UITextFieldDelegate {
    
    var viewIndex: Int?
    var step: GuideStep?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isEditing = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    public func addBullet(bullet: GuideStep.GuideLine) {
        self.step!.lines.append(bullet)
        tableView.reloadData()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let stepBulletCell = textField.superview?.superview as! GuideEditStepBulletTableViewCell
        let index = stepBulletCell.lineIndex
        self.step?.lines[index!].text_raw = textField.text ?? ""
        
        self.notifyParentToUpdate()
        
        self.resignFirstResponder()
    }
    
    func notifyParentToUpdate() {
        let parentView = self.parent as! GuideEditPageViewController
        
        parentView.updateStep(step: self.step!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension GuideEditStepViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + step!.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideEditStepHeaderCell", for: indexPath) as! GuideStepEditHeaderTableViewCell
            
            if let imageArray = self.step?.media?.data {
                cell.setCollectionViewWith(imageArray: imageArray)
                cell.pageControl.numberOfPages = (imageArray.count)
            }
        
            cell.parentView = self
            
            return cell
        } else if indexPath.row == 1 + step!.lines.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideEditStepAddBullet", for: indexPath) as! GuideEditStepAddTableViewCell
            
            cell.parentView = self
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guideEditStepLine", for: indexPath) as! GuideEditStepBulletTableViewCell
            
            let text = self.step!.lines[indexPath.row - 1].text_raw
            
            cell.textField.text = text
            cell.textField.delegate = self
            cell.lineIndex = indexPath.row - 1
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0 && indexPath.row < 1 + step!.lines.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.step!.lines.remove(at: indexPath.row - 1)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        self.notifyParentToUpdate()
    }
}
