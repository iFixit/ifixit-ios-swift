//
//  MediaManagerImageUploadViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/15/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class MediaManagerImageUploadViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadButton: UIButton!
    
    var imageToUpload: UIImage?
    var api: APIManager?
    var uploadedImage: MediaManagerImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil);
        
        if let imageToUpload = imageToUpload {
            self.imageView.image = imageToUpload
        }
    }
    
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        uploadButton.setTitle("Uploading...", for: .normal)
        loadingIndicator.isHidden = false
        
        textField.resignFirstResponder()
        let filename = textField.text!
        
        api?.uploadToMediaManager(image: self.imageToUpload!, filename: filename, completion: { (mediaImage: MediaManagerImage) in
            self.uploadedImage = mediaImage
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToMediaManager", sender: self)
            }
        })
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMediaManager", sender: self)
    }
}

extension MediaManagerImageUploadViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
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
        uploadButton.isEnabled = (textField.text?.count)! > 0
    }
}
