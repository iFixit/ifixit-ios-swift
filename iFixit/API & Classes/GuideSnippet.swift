//
//  GuideSnippet.swift
//  iFixit
//
//  Created by Tanner Villarete on 2/8/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import Foundation

struct GuideSnippet: Codable {
    let category: String
    let guideid: Int
    let image: Image?
    let modified_date: Int
    let title: String
    let type: String
    let url: String
    let userid: Int
    let username: String
    let revisionid: Int
    
    init(json: [String: Any]) {
        category = json["category"] as? String ?? ""
        guideid = json["guideid"] as? Int ?? -1
        image = json["image"] as? Image
        modified_date = json["modified_date"] as? Int ?? -1
        title = json["title"] as? String ?? ""
        type = json["type"] as? String ?? ""
        url = json["url"] as? String ?? ""
        userid = json["userid"] as? Int ?? -1
        username = json["username"] as? String ?? ""
        revisionid = json["revisionid"] as? Int ?? -1
    }
}
