//
//  GuideEditViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/2/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideEditViewController: UIViewController {
    
    var guide: Guide?
    var api: APIManager?
    var user: User?
    var pageViewController: GuideEditPageViewController?
    var startIndex = 0
    var stepUpdatingQueue = [Int:GuideStep]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            self.api = APIManager(user: user)
        }
        
        if let _ = guide {
            setupToolbar()
        }
    }
    
    public func setupToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 44, width: UIScreen.main.bounds.size.width, height: 44))
        toolbar.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        let moveButton = UIBarButtonItem(title: "Move", style: .done, target: self, action: #selector(self.moveButtonPressed(_:)))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonPressed(_:)))
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.addButtonPressed(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil);
        
        toolbar.items = [moveButton, flexibleSpace, trashButton, flexibleSpace, addButton]
        view.addSubview(toolbar)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func moveButtonPressed(_ sender: Any) {
        print("MOVE ME")
    }
    
    @objc func deleteButtonPressed(_ sender: Any) {
        print("MOVE ME")
    }
    
    @objc func addButtonPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose where to add the new step", preferredStyle: .actionSheet)
        
        let insertAction = UIAlertAction(title: "New step here", style: .default){ (UIAlertAction) in
            self.insertStep()
        }
        let appendAction = UIAlertAction(title: "New step at end", style: .default)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(insertAction)
        optionMenu.addAction(appendAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        showLoading()
        if ((pageViewController?.hasEditedGuide)!) {
            syncSummary()
        } else {
            syncPendingSteps()
        }
        
    }
    
    func syncSummary() {
        let updatedGuide = pageViewController?.guide
        var parameters = [String: Any]()
        
        if ((pageViewController?.hasEditedGuide)!) {
            parameters["title"] = updatedGuide!.title
            parameters["summary"] = updatedGuide!.summary
            parameters["public"] = updatedGuide?.public
            if (updatedGuide?.image != nil) {
                parameters["image"] = updatedGuide?.image?.id
            }
            api!.updateGuide(guide: updatedGuide!, parameters: parameters) { (guide: Guide) in
                DispatchQueue.main.async {
                    self.syncPendingSteps()
                }
            }
        }
    }
    
    func syncPendingSteps() {
        if let pendingStepEdits = pageViewController?.pendingStepEdits {
            if pendingStepEdits.count == 0 {
                self.hideLoading()
                return
            }
            for (stepid, step) in pendingStepEdits {
                stepUpdatingQueue[stepid] = step
                
                self.api!.updateStep(step: step) { (updatedStep: GuideStep) in
                    DispatchQueue.main.async {
                        self.stepUpdatingQueue.removeValue(forKey: updatedStep.stepid)
                        if self.stepUpdatingQueue.count == 0 {
                            self.hideLoading()
                        }
                    }
                }
            }
        }
    }
    
    func showLoading() {
        let alert = UIAlertController(title: nil, message: "Updating guide...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func hideLoading() {
        performSegue(withIdentifier: "unwindToGuideView", sender: self)
    }
    
    func insertStep() {
        let _ = pageViewController!.getCurrentIndex()
        //        let currentStep = pageViewController.
//        let templateStep = GuideStep(guideid: (guide?.guideid)!, lines: [], revisionid: (guide?.revisionid)!, stepid: -1, title: "New Step")
//        pageViewController!.addStep(at: stepIndex)
//        print("Inserted Step")
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPageViewController" {
            let pageViewController = segue.destination as! GuideEditPageViewController
            pageViewController.guide = self.guide
            pageViewController.user = self.user
            pageViewController.parentController = self
            pageViewController.currentIndex = self.startIndex
            self.pageViewController = pageViewController
        }
    }
}
