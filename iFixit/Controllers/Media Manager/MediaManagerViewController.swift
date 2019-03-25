//
//  MediaManagerViewController.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/6/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class MediaManagerViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var noImagesView: UIView!
    @IBOutlet weak var imageCollectionView: UIView!
    
    var imagePicker = UIImagePickerController()
    
    var collectionViewController: MediaManagerCollectionViewController?
    var addImageViewController: MediaManagerDefaultViewController?
    
    var user: User?
    var api: APIManager?
    var selectedImage: MediaManagerImage?
    var imageToUpload: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        if let user = user {
            self.api = APIManager(user: user)
            self.getImages()
        } else {
            print("Didn't get user for media manager")
        }
    }
    
    @IBAction func addMediaButtonPressed(_ sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: nil, message: "Add a photo", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.showCamera()
        }
        let chooseAction = UIAlertAction(title: "Choose from library", style: .default) { _ in
            self.showImagePicker()
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(chooseAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    public func showImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    public func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera not available", message: "Try using a phone.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Bummer", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        
        self.imageToUpload = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let imageUploadVC = storyBoard.instantiateViewController(withIdentifier: "imageUploadView") as! MediaManagerImageUploadViewController
        imageUploadVC.api = self.api
        imageUploadVC.imageToUpload = self.imageToUpload!
        self.present(imageUploadVC, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func getImages() {
        api!.getUserImages(user: self.user) { (images: [MediaManagerImage]) in
            DispatchQueue.main.async {
                self.updateImages(images: images)
                self.loadingView.fadeOut(0.3, onCompletion: {
                    if images.count > 0 {
                        self.imageCollectionView.fadeIn()
                    } else {
                        self.noImagesView.fadeIn()
                    }
                })
            }
        }
    }
    
    public func setSelectedImage(image: MediaManagerImage) {
        self.selectedImage = image
        performSegue(withIdentifier: "unwindFromMediaManager", sender: self)
    }
    
    public func updateImages(images: [MediaManagerImage]) {
        self.collectionViewController!.setImages(images: images)
    }
    
    @IBAction func unwindToMediaManager(sender: UIStoryboardSegue) {
        print("UNWINDING")
        if let imageUploadVC = sender.source as? MediaManagerImageUploadViewController, let mediaImage = imageUploadVC.uploadedImage {
            print("adding new image")
            var images = collectionViewController?.images
            images!.append(mediaImage)
            self.updateImages(images: images!)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let collectionView = segue.destination as? MediaManagerCollectionViewController {
            self.collectionViewController = collectionView
        } else if let defaultView = segue.destination as? MediaManagerDefaultViewController {
            self.addImageViewController = defaultView
        }
    }
}
