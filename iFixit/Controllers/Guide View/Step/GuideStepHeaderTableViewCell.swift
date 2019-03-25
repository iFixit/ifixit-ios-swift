//
//  GuideStepHeaderTableViewCell.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/2/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideStepHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var stepNumber: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var parentView: GuideStepViewController?
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let rootParent = self.parentView!.parent!.parent! as! GuideViewController
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = rootParent.view.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        newImageView.fadeIn()
        
        rootParent.view.addSubview(newImageView)
        
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.fadeOut(0.3, onCompletion: {
            sender.view?.removeFromSuperview()
        })
        
    }
    
    var imageArray = [Image]()
    var currentPage = 0
    
    func setCollectionViewWith(imageArray: [Image]) {
        self.imageArray = imageArray
        self.collectionView.isPagingEnabled = true
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.reloadData()
        self.pageControl.hidesForSinglePage = true
    }
}

extension GuideStepHeaderTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guideMediaCell", for: indexPath) as! GuideMediaCollectionViewCell
        
        cell.mediaImage.downloaded(from: self.imageArray[indexPath.row].original ?? "")
        cell.imageData = self.imageArray[indexPath.row]
        
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(_:)))
        cell.mediaImage.isUserInteractionEnabled = true
        cell.mediaImage.tag = indexPath.row
        cell.mediaImage.addGestureRecognizer(pictureTap)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let pageWidth = scrollView.frame.width
        self.currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        self.pageControl.currentPage = self.currentPage
    }
}
