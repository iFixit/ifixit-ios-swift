
//
//  GuideStepEditHeaderTableViewCell.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/11/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

class GuideStepEditHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var parentView: GuideEditStepViewController?
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

extension GuideStepEditHeaderTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guideEditMediaCell", for: indexPath) as! GuideEditMediaCollectionViewCell
        
        cell.mediaImage.downloaded(from: self.imageArray[indexPath.row].standard ?? "")
        cell.imageData = self.imageArray[indexPath.row]
        
        cell.mediaImage.isUserInteractionEnabled = true
        cell.mediaImage.tag = indexPath.row
        
        return cell
    }
    
    
}
