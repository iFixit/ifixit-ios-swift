//
//  MediaManagerDefaultViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/6/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class MediaManagerDefaultViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addMediaButtonPressed(_ sender: UIButton) {
        let parentVC = self.parent as! MediaManagerViewController
        
        parentVC.showImagePicker()
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
