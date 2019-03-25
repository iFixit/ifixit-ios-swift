//
//  GuideViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/2/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {
    @IBOutlet weak var pageViewContainer: UIView!
    var pageViewController: GuidePageViewController?
    @IBOutlet weak var loadingIndicator: UIView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var guideSnippet: GuideSnippet?
    var api: APIManager?
    var user: User?
    var guide: Guide?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            self.api = APIManager(user: user)
        }
        
        self.editButton.isEnabled = guide != nil
    }
    
    func childViewLoadedGuide(guide: Guide) {
        loadingIndicator.fadeOut(0.3) {
            self.pageViewContainer.fadeIn(0.5)
        }
        self.guide = guide
        self.editButton.isEnabled = true
    }
    
    func updateToolbar(currentIndex: Int) {
        print("On page \(currentIndex)")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageViewController" {
            let pageViewController = segue.destination as! GuidePageViewController
            
            pageViewController.guideSnippet = self.guideSnippet
            pageViewController.user = self.user
            pageViewController.parentController = self
            self.pageViewController = pageViewController
        }
        
        else if segue.identifier == "editExistingGuide" {
            let guideEditVC = segue.destination as! GuideEditViewController
            
            guideEditVC.guide = self.guide
            guideEditVC.user = self.user
        }
    }
    
    @IBAction func unwindToGuideView(segue: UIStoryboardSegue) {
        self.pageViewContainer.fadeOut(0.3) {
            self.loadingIndicator.fadeIn(0.5)
        }
        self.pageViewController!.setupGuide()
    }
    
}
