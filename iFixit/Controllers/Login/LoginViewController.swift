//
//  LoginViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 1/29/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        loadingIndicator.isHidden = false
        let api = APIManager(user: nil)
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        api.login(username: usernameField!.text!, password: passwordField!.text!, completion: {(user: User?, error: Error?) -> () in
            DispatchQueue.main.async {
                self.user = user
                //self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "unwindToGuidesList", sender: self)
            }
        })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
