//
//  GuidesViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 2/8/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuidesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userButton: UIBarButtonItem!
    var refresher: UIRefreshControl!
    
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("loggedInUser")
    var ourDefaults = UserDefaults.standard
    var user: User?
    var api: APIManager?
    
    var guides = [GuideSnippet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.fadeIn(1)
        
        if (!getLoggedInUser()) {
            showLoginModal()
        } else {
            print("User token: \(user!.authToken)")
            userButton.title = self.user!.unique_username
            api = APIManager(user: user!)
            getGuides()
        }
        addPullToRefresh()
    }
    
    func addPullToRefresh() {
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.refreshControl = self.refresher
    }
    
    @objc func loadData() {
        self.refresher.beginRefreshing()
        getGuides()
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    // MARK: Actions
    @IBAction func userButtonPressed(_ sender: UIBarButtonItem) {
        
        let dialog = UIAlertController(title: self.user!.username, message: "Currently logged in user", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) {
            UIAlertAction in
            DispatchQueue.main.async {
                self.deleteLoggedInUser()
            }
        }
        dialog.addAction(logoutAction)
        dialog.addAction(cancelAction)
        
        present(dialog, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.collectionView)
        
        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            let optionMenu = UIAlertController(title: nil, message: "Options", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete Guide", style: .destructive) { _ in
                let guideSnippet = self.guides[indexPath.row]
                
                self.api!.deleteGuide(guideid: guideSnippet.guideid, revisionid: guideSnippet.revisionid, completion: { (val: Bool) in
                    print("Deleted guide: \(val)")
                    DispatchQueue.main.async {
                        self.getGuides()
                    }
                })
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            print("couldn't find index path")
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowGuideView":
            guard let guideVC = segue.destination as? GuideViewController else {
                fatalError("Unexpected Destination: \(segue.destination)")
            }
            
            guard let selectedGuideCell = sender as? GuidesCollectionViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = collectionView.indexPath(for: selectedGuideCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedGuide = guides[indexPath.row]
            guideVC.guideSnippet = selectedGuide
            guideVC.user = self.user
        case "ShowGuideEdit":
            guard let guideEditVC = segue.destination as? GuideEditViewController else {
                fatalError("Couldn't instantiate Guide Edit View")
            }
            
            guideEditVC.user = self.user
        default:
            fatalError("Unexpected Segue identifier; \(String(describing: segue.identifier))")
        }
    }
    
    @IBAction func unwindToGuidesList(sender: UIStoryboardSegue) {
        if let loginViewController = sender.source as? LoginViewController, let user = loginViewController.user {
            self.user = user
            self.api = APIManager(user: user)
            updateLoggedInUser()
            getGuides()
        } else if let _ = sender.source as? GuideViewController {
            getGuides()
        }
    }
    
    private func getGuides() {
        api!.getGuides(completion: { (guideSnippets: [GuideSnippet]) -> () in
            self.guides = guideSnippets
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.stopRefresher()
            }
        })
    }
    
    private func getLoggedInUser() -> Bool {
        if let _ = ourDefaults.object(forKey: "lastUpdate") as? Date {
            do {
                let data = try Data(contentsOf: GuidesViewController.archiveURL)
                let decoder = JSONDecoder()
                let tempUser = try decoder.decode(User.self, from: data)
                self.user = tempUser
                return true
            } catch {
                print(error)
            }
        }
        print("No user")
        return false
    }
    
    private func deleteLoggedInUser() {
        self.user = nil
        do {
            //try Data(contentsOf: GuidesViewController.archiveURL).removeAll()
            try FileManager().removeItem(at: GuidesViewController.archiveURL)
            showLoginModal()
        } catch {
            print(error)
        }
        
    }
    
    private func updateLoggedInUser() {
        // persist data
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self.user)
            try jsonData.write(to: GuidesViewController.archiveURL)
            userButton.title = self.user!.username
            
            // timestamp last update
            ourDefaults.set(Date(), forKey: "lastUpdate")
        } catch {
            print(error)
        }
    }
    
    private func showLoginModal() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        {
            present(vc, animated: true, completion: nil)
        }
        
    }
}

extension GuidesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.backgroundColor = .gray
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuidesCell", for: indexPath) as! GuidesCollectionViewCell
        
        cell.guideTitle.text = guides[indexPath.row].title
        let imageUrl = guides[indexPath.row].image?.standard
        if (imageUrl != nil) {
            cell.guideImage.downloaded(from: imageUrl!)
        } else {
            cell.guideImage.image = UIImage(named: "placeholder")
        }
        
        cell.contentView.alpha = 0
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        cell.addGestureRecognizer(lpgr)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, animations: {
            cell.contentView.alpha = 1
        })
    }
}
