//
//  MediaManagerImage.swift
//  iFixit
//
//  Created by Tanner Villarete on 3/6/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

struct MediaManagerImage: Codable {
    var image: Image
    var width: Int
    var height: Int
    var ratio: String
//    var exif: Exif
//    
//    struct Exif: Codable {
//        var FileName: String
//        var FileSize: Int
//        var FileType: Int
//    }
}
