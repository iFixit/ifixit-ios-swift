//
//  GuideEditPageViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/3/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideEditPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var guide: Guide?
    var api: APIManager?
    var user: User?
    var parentController: GuideEditViewController?
    var currentIndex = 0
    var pendingIndex = -1
    var pendingStepEdits = [Int : GuideStep]()
    var hasEditedGuide = false
    
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            self.api = APIManager(user: user)
        }
        
        if let _ = guide {
            setupExistingGuide()
        } else {
            self.pages = [self.getViewController(withIdentifier: "guideEditSetup")]
        }
        
        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([self.pages[currentIndex]], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    
    public func updateStep(step: GuideStep) {
        pendingStepEdits[step.stepid] = step
        print(step)
        print(pendingStepEdits.keys)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard pages.count > previousIndex else {
            return nil
        }
        
        if let newVC = pages[previousIndex] as? GuideEditSummaryViewController {
            newVC.viewIndex = previousIndex
            newVC.guide = self.guide
            newVC.user = self.user
            return newVC
        } else if let newVC = pages[previousIndex] as? GuideEditStepViewController {
            newVC.viewIndex = previousIndex
            return newVC
        } else if let newVC = pages[previousIndex] as? GuideEditSetupViewController {
            newVC.viewIndex = previousIndex
            return newVC
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        guard pages.count > nextIndex else {
            return nil
        }
        
        if let newVC = pages[nextIndex] as? GuideEditSummaryViewController {
            newVC.viewIndex = nextIndex
            newVC.guide = self.guide
            newVC.user = self.user
            return newVC
        } else if let newVC = pages[nextIndex] as? GuideEditStepViewController {
            newVC.viewIndex = nextIndex
            return newVC
        } else if let newVC = pages[nextIndex] as? GuideEditSetupViewController {
            newVC.viewIndex = nextIndex
            return newVC
        }
        
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
        
        // This stupid stuff is so that I can get the current index of the pageController.
        if let summaryVC = pendingViewControllers[0] as? GuideEditSummaryViewController {
            self.pendingIndex = summaryVC.viewIndex!
        } else if let stepVC = pendingViewControllers[0] as? GuideEditStepViewController {
            self.pendingIndex = stepVC.viewIndex!
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.currentIndex = self.pendingIndex
    }
    
    // MARK: View Setup
    
    public func createGuide(focus: String, type: String, subject: String) {
        print("Setting up \(focus) \(type)...")
        
        self.api!.createGuide(category: focus, type: type, subject: subject) {
            (guide: Guide) in
            DispatchQueue.main.async {
                self.guide = guide
                self.pages = [
                    self.getViewController(withIdentifier: "guideEditSummary")
                ]
                if let firstVC = self.pages.first {
                    self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
                }
                
                self.parentController?.guide = guide
                self.parentController?.setupToolbar()
            }
        }
    }
    
    public func setupExistingGuide() {
        var newPages = [self.getViewController(withIdentifier: "guideEditSummary")]
        for stepView in self.getGuideSteps() {
            newPages += [stepView]
        }
        self.pages = newPages
    }
    
    private func getGuideSteps() -> [UIViewController]
    {
        var stepVCs = [UIViewController]()
        
        for step in (guide?.steps)! {
            let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "guideStepEdit") as! GuideEditStepViewController
            VC.step = step
            stepVCs += [VC]
        }
        
        return stepVCs
    }
    
    public func getCurrentIndex() -> Int {
        print("found at index: \(self.currentIndex)")
        return self.currentIndex
    }
    
    public func addStep(at index: Int) {
        let newVC = self.getViewController(withIdentifier: "guideStepEdit") as! GuideEditStepViewController
        
        newVC.viewIndex = index + 1
        
        pages.insert(newVC, at: index + 1)
        
        self.setViewControllers([self.pages[index + 1]], direction: .forward, animated: true, completion: nil)
    }
    
    private func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        print("Getting view: \(identifier)")
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        
        if let summaryVC = VC as? GuideEditSummaryViewController, guide != nil {
            summaryVC.guide = guide
            summaryVC.user = user
            summaryVC.viewIndex = 0
            return summaryVC
        }
        
        return VC
    }
    
}
