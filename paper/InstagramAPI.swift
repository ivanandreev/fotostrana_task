//
//  InstagramClient.swift
//  Paper
//
//  Created by Иван Андреев on 21.12.15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import Foundation
import OAuthSwift
import SwiftyJSON
import Haneke

class InstagramAPI {
    
    private let consumerKey = "4062b2edcc7f4d2fb0fb04965d151757"
    private let consumerSecret = "26740ff9347340cbb1beec6b78adfe31"
    
    private let authorizeUrl = "https://api.instagram.com/oauth/authorize"
    private let responseType = "token"
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let cache = Shared.dataCache
    var oauthswift: OAuth2Swift!    
    
    class var sharedInstance: InstagramAPI {
        struct Static {
            static let instance = InstagramAPI()
        }
        return Static.instance
    }
    
    init() {
        self.oauthswift = OAuth2Swift(consumerKey: consumerKey, consumerSecret: consumerSecret, authorizeUrl: authorizeUrl, responseType: responseType)
    }
    
    func authorize() {

        let url = NSURL(string: "oauth-swift://oauth-callback/instagram")!
        let scope = "basic+likes"
        let state = "INSTAGRAM"
        
        self.oauthswift.authorizeWithCallbackURL(
            url,
            scope: scope,
            state: state,
            success: { credential, response, parameters in
                self.defaults.setObject(credential.oauth_token, forKey: "token")
                print(credential.oauth_token)
                NSLog("Authorize success")
            },
            failure: { error in
                NSLog("Authorize failure: %@",error.localizedDescription)
            }
        )
    }
    
    func getMediaRecent(oauth_token: String, completion: (AnyObject?) -> Void) {
        let url:String = "https://api.instagram.com/v1/users/self/media/recent/?access_token=\(oauth_token)"

        self.oauthswift.client.get(url, parameters: ["count":10],
            success: {
                data, response in
                do {
                    let postsData = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                    let postsJSON = JSON(postsData)
                    var posts = [Post]()
                    for post in postsJSON["data"].array! {
                        let post = Post(json: post)
                        posts.append(post)
                    }
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(posts)
                        }
                    }
                    
                    NSLog("GetMediaRecent success")
                } catch _ {
                    NSLog("JSON Serialization failure")
                }
            }, failure: { error in
                NSLog("GetMediaRecent failure: %@",error.localizedDescription)
        })
    }
    
    func getSelfFollows(oauth_token: String, completion: (AnyObject?) -> Void) {
        let url:String = "https://api.instagram.com/v1/users/self/follows?access_token=\(oauth_token)"
        
        self.oauthswift.client.get(url, parameters: ["count":10],
            success: { data, response in
                self.handleSelfFollowers(data, oauth_token: oauth_token, completion: { result in completion(result) })
                // Cache
                self.cache.remove(key: "followers")
                self.cache.set(value: data, key: "followers")
            },
            failure: { error in
                NSLog("GetSelfFollows failure: %@",error.localizedDescription)
                
                self.cache.fetch(key: "followers").onSuccess({data in
                    self.handleSelfFollowers(data, oauth_token: oauth_token, completion: {result in completion(result) })
                }).onFailure({ error in
                    NSLog("GetSelfFollows from cache failure: %@",error!.localizedDescription)
                })
            })
    }
    
    private func handleSelfFollowers(data: NSData, oauth_token: String, completion: (AnyObject?) -> Void) {
        do {
            let usersData = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            let usersJSON = JSON(usersData)
            
            var posts = [Post]()
            let group = dispatch_group_create()
            for userJSON in usersJSON["data"].array! {
                let user = User(json: userJSON)
                
                
                dispatch_group_enter(group)
                self.getUserMediaRecent(oauth_token ,userid: user.id!, count: 3) { result in
                    if let array = result as? [Post] {
                        posts.appendContentsOf(array)
                    }
                    dispatch_group_leave(group)
                }
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue()) {
                let sortedPosts = posts.sort({ $0.createdTime!.compare($1.createdTime!) == NSComparisonResult.OrderedDescending })
                completion(sortedPosts)
            }
        } catch _ {
            NSLog("JSON Serialization failure")
        }

    }
    
    func getUserMediaRecent(oauth_token: String, userid: String, count: Int, completion: (AnyObject?) -> Void) {
        let url: String = "https://api.instagram.com/v1/users/\(userid)/media/recent/?access_token=\(oauth_token)"
        
        let parameters = ["count":count]
        
        self.oauthswift.client.get(url, parameters: parameters,
            success: {
                data, response in
                self.handleUserMedia(data, completion: {result in completion(result)})
                
                // Cache
                self.cache.remove(key: "user_media_\(userid)")
                self.cache.set(value: data, key: "user_media_\(userid)")

            }, failure: { error in
                NSLog("GetUserMediaRecent failure: %@",error.localizedDescription)
                self.cache.fetch(key: "user_media_\(userid)").onSuccess({ data in
                    self.handleUserMedia(data, completion: { result in completion(result) })
                }).onFailure({ error in
                    NSLog("GetUserMediaRecent from cache failure: %@",error!.localizedDescription)
                })
                
        })
    }
    
    private func handleUserMedia(data: NSData, completion: (AnyObject?) -> Void) {
        do {
            let postsData = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            let postsJSON = JSON(postsData)
            
            var posts = [Post]()
            for post in postsJSON["data"].array! {
                let post = Post(json: post)
                posts.append(post)
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(posts)
                }
            }
            NSLog("GetUserMediaRecent success")
        } catch _ {
            NSLog("JSON Serialization failure")
        }

    }
    
    func setLikeMedia(oauth_token: String, mediaId: String) {
        let url = "https://api.instagram.com/v1/media/\(mediaId)/likes?access_token=\(oauth_token)"
        
        self.oauthswift.client.post(url, parameters: [:], headers: ["access_token":oauth_token], success: {
            data, response in
                NSLog("SetLikeMedia success")
            }, failure: {
                error in
            NSLog("SetLikeMedia failure: %@",error.localizedDescription)
        })
    }
    
    func removeLikeMedia(oauth_token: String, mediaId: String) {
        let url = "https://api.instagram.com/v1/media/\(mediaId)/likes?access_token=\(oauth_token)"
        
        self.oauthswift.client.delete(url, success: {
            data, response in
            NSLog("RemoveLikeMedia success")
            }, failure: {
                error in
                NSLog("RemoveLikeMedia failure: %@",error.localizedDescription)
        })
    }
}