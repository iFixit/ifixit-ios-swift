//
//  User.swift
//  iFixit
//
//  Created by Tanner Villarete on 2/8/19.
//  Copyright © 2019 Tanner Villarete. All rights reserved.
//

import UIKit

struct User: Codable {
    var username: String
    var unique_username: String
    var userid: Int
    var authToken: String
    var reputation: Int
    var join_date: Int
    var image: Image?
}
