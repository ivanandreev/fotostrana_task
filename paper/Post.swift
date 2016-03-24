//
//  InstaPost.swift
//  Paper
//
//  Created by Andreev Ivan on 22/12/15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import Foundation
import SwiftyJSON

class  Post {
    
    var userId: String?
    var mediaId: String?
    var profileImage: String?
    var username: String?
    var createdTime: NSDate?
    var image: String?
    var text: String?
    var likesCount: Int?
    var liked: Bool?
    var thumbnailURL: String?
    
    init(json: JSON) {
        
        self.userId = json["user"]["id"].string
        self.mediaId = json["id"].string
        self.profileImage = json["user"]["profile_picture"].string
        self.username = json["user"]["username"].string
        self.createdTime = getDateDiff(json["created_time"].doubleValue)
        self.image = json["images"]["standard_resolution"]["url"].string
        self.text = json["caption"]["text"].string
        self.likesCount = json["likes"]["count"].int
        self.thumbnailURL = json["images"]["thumbnail"]["url"].string        
        self.liked = json["user_has_liked"].bool                
    }
    
    func getDateDiff(timestamp: Double) -> NSDate {
        return NSDate(timeIntervalSince1970: timestamp)
    }
}