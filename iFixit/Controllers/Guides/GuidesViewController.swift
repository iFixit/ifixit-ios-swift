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
    
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("loggedInUser")
    var ourDefaults = UserDefaults.standard
    var user: User?
    
    var guides = [GuideSnippet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.fadeIn(1)
        
        if (!getLoggedInUser()) {
            showLoginModal()
        } else {
            print("Loading guides")
            userButton.title = self.user!.unique_username
            getGuides(user: self.user!)
        }
    }
    
    // MARK: Actions
    @IBAction func userButtonPressed(_ sender: UIBarButtonItem) {
        
        let dialog = UIAlertController(title: self.user!.username, message: "Logged in 2 days ago", preferredStyle: .alert)
        
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
            print("Editing or creating a new guide")
        default:
            fatalError("Unexpected Segue identifier; \(String(describing: segue.identifier))")
        }
    }
    
    @IBAction func unwindToGuidesList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LoginViewController, let user = sourceViewController.user {
            self.user = user
            updateLoggedInUser()
            getGuides(user: user)
        } else if let _ = sender.source as? GuideViewController {
            print("Unwound to guide list from Guide View")
        }
    }
    
    private func getGuides(user: User) {
        let api = APIManager(user: user)
        
        api.getGuides(completion: { (guideSnippets: [GuideSnippet]) -> () in
            self.guides = guideSnippets
            DispatchQueue.main.async {
                self.collectionView.reloadData()
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
            print("Saved user \(self.user!.username)")
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
        cell.guideImage.downloaded(from: guides[indexPath.row].image?.standard ?? "")
        cell.contentView.alpha = 0
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, animations: {
            cell.contentView.alpha = 1
        })
    }
}
