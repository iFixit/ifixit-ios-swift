//
//  GuideViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/2/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {
    
    var guideSnippet: GuideSnippet?
    var api: APIManager?
    var user: User?
    @IBOutlet weak var pageViewContainer: UIView!
    var pageViewController: GuidePageViewController?
    @IBOutlet weak var loadingIndicator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            self.api = APIManager(user: user)
        }
    }
    
    func notifyParent() {
        loadingIndicator.fadeOut(0.3) {
            self.pageViewContainer.fadeIn(0.5)
        }
        
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
    }
    
}
