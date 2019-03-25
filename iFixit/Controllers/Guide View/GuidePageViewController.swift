//
//  GuidePageViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/2/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuidePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "guideLoadingView")
        ]
    }()
    var guideSnippet: GuideSnippet?
    var guide: Guide?
    var api: APIManager?
    var user: User?
    var parentController: GuideViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        if let myView = view?.subviews.first as? UIScrollView {
            myView.canCancelContentTouches = false
        }
        
        // After confirming the user has been retrieved, query the API to receive the relevant guide using guideSnippet's guideid
        if let user = user, let _ = guideSnippet {
            self.api = APIManager(user: user)
            setupGuide()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard pages.count > previousIndex else {
            return nil
        }
        
        if let newVC = pages[previousIndex] as? GuideStepViewController {
            newVC.stepNumber = previousIndex
            return newVC
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard pages.count > nextIndex, nextIndex < pages.count else {
            return nil
        }
        
        if let newVC = pages[nextIndex] as? GuideStepViewController {
            newVC.stepNumber = nextIndex
            return newVC
        }
        
        return pages[nextIndex]
    }
    
    public func goToNextPage(){
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }
    
    private func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    private func getSummaryView() -> UIViewController {
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "guideSummaryView") as! GuideSummaryViewController
        
        VC.guide = self.guide
        
        return VC
    }
    
    private func getGuideSteps() -> [UIViewController] {
        var stepVCs = [UIViewController]()
        
        for step in (guide?.steps)! {
            let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "guideStepView") as! GuideStepViewController
            VC.step = step
            stepVCs += [VC]
        }
        
        return stepVCs
    }
    
    public func setupGuide() {
        api!.getGuide(guideid: guideSnippet!.guideid, completion: { (guide: Guide) -> () in
            self.guide = guide
            
            DispatchQueue.main.async {
                var newPages = [self.getSummaryView()]
                for stepView in self.getGuideSteps() {
                    newPages += [stepView]
                }
                self.pages = newPages
                if let firstVC = self.pages.first {
                    self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
                }
                self.parentController!.childViewLoadedGuide(guide: guide)
            }
        })
    }
}
