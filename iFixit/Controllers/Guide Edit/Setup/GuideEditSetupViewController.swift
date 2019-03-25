//
//  GuideEditSetupViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/3/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideEditSetupViewController: UIViewController {
    @IBOutlet weak var guideType: UITextField!
    @IBOutlet weak var deviceType: UITextField!
    @IBOutlet weak var partTypeLabel: UILabel!
    @IBOutlet weak var partType: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var createButton: UIButton!
    
    var pickerView = UIPickerView()
    var viewIndex: Int?
    
    var guideTypes = ["Select a type", "Replacement", "Disassembly", "Teardown", "Technique"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceType.delegate = self
        guideType.delegate = self
        
        self.setupPickerView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        let parentVC = self.parent as! GuideEditPageViewController
        
        parentVC.createGuide(focus: deviceType.text!, type: guideType.text!.lowercased(), subject: partType.text!)
        
        self.view.endEditing(true)
        
        loadingIndicator.isHidden = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func donePicker(sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    @IBAction func guideTypeSelected(_ sender: UITextField) {
        if guideType.text == "Replacement" {
            partType.fadeIn()
            partTypeLabel.fadeIn()
        } else {
            partTypeLabel.fadeOut()
            partType.fadeOut()
        }
    }
    
    private func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker(sender:)))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        guideType.inputView = pickerView
        guideType.inputAccessoryView = toolBar
    }
}

extension GuideEditSetupViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resignFirstResponder()
        
        validateTextFields()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validateTextFields()
    }
    
    func validateTextFields() {
        createButton.isEnabled = guideType.text != "" && deviceType != nil && pickerView.selectedRow(inComponent: 0) != 0
    }
}

extension GuideEditSetupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return guideTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return guideTypes[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            guideType.text = ""
        } else {
            guideType.text = guideTypes[row]
        }
    }
}
