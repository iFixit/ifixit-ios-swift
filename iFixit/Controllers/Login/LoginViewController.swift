//
//  LoginViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 1/29/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil);
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        loadingIndicator.isHidden = false
        let api = APIManager(user: nil)
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        api.login(username: usernameField!.text!, password: passwordField!.text!, completion: {(user: User) -> () in
            self.user = user
            DispatchQueue.main.async {
                //self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "unwindToGuidesList", sender: self)
            }
        })
    }
    
    @IBAction func viewWasTapped(_ sender: UITapGestureRecognizer) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -50 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resignFirstResponder()
        
        validateTextFields()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        validateTextFields()
        return true
    }
    
    func validateTextFields() {
        loginButton.isEnabled = (usernameField.text?.count)! > 0 && (passwordField.text?.count)! > 0
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
