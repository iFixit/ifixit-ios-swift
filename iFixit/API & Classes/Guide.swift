//
//  Guide.swift
//  iFixit
//
//  Created by Tanner Villarete on 2/11/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

struct Guide: Codable {
    var author: Author
    var category: String
    var difficulty: String
    var guideid: Int
    var image: Image?
    var introduction_raw: String?
    var modified_date: Int
    var revisionid: Int
    var `public`: Bool
    var steps: [GuideStep]
    var subject: String
    var summary: String
    var time_required_min: Int
    var time_required_max: Int
    var title: String
    var type: String
    var url: String
}

struct Author: Codable {
    var image: Image?
    var join_date: Int?
    var reputation: Int
    var userid: Int
    var username: String?
}

struct Media: Codable {
    var data: [Image]
    var type: String
}

struct Image: Codable {
    var guid: String
    var id: Int
    var large: String?
    var medium: String?
    var mini: String?
    var original: String?
    var standard: String?
    var thumbnail: String?
}

struct GuideStep: Codable {
    var guideid: Int
    var lines: [GuideLine]
    var media: Media?
    var revisionid: Int
    var stepid: Int
    var title: String?
    
    struct GuideLine: Codable {
        var bullet: String
        var level: Int
        var text_raw: String
        
        init(bullet: String, level: Int, text_raw: String) {
            self.bullet = bullet 
            self.level = level
            self.text_raw = text_raw
        }
    }
    
    init(guideid: Int, lines: [GuideLine], revisionid: Int, stepid: Int, title: String) {
        self.guideid = guideid
        self.lines = lines
        self.revisionid = revisionid
        self.stepid = stepid
        self.title = title
    }
}

struct RequestBody: Codable {
    var lines: [StepLine]
    
    init(lines: [StepLine]) {
        self.lines = lines
    }
}

struct StepLine: Codable {
    var bullet: String
    var level: Int
    var text: String
    
    init(bullet: String, level: Int, text: String) {
        self.bullet = bullet
        self.level = level
        self.text = text
    }
}
