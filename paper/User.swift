//
//  User.swift
//  Paper
//
//  Created by Иван Андреев on 21.12.15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {
    var username: String?
    var id:String?
    
    init(json: JSON) {
        self.username = json["username"].string
        self.id = json["id"].string
    }
}