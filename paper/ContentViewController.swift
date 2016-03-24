//
//  ContentViewController.swift
//  Paper
//
//  Created by Иван Андреев on 21.12.15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    {
        didSet {
            self.profileImage.userInteractionEnabled = true
            let recognizer = UITapGestureRecognizer(target: self, action: "imageTap:")
            self.profileImage.addGestureRecognizer(recognizer)
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdtimeLabel: UILabel! {
        didSet {
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(self.post!.createdTime!) >= 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            self.createdtimeLabel.text = formatter.stringFromDate(self.post!.createdTime!)
        }
    }
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var captionText: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    {
        didSet {
            self.likeImage.userInteractionEnabled = true
            let recognizer = UITapGestureRecognizer(target: self, action: "likeHandler:")
            self.likeImage.addGestureRecognizer(recognizer)
        }
    }
    

    
    var liked: Bool? {
        didSet {
            if self.liked == true {
                self.likeImage?.image = UIImage(named: "liked_icon")
            } else {
                self.likeImage?.image = UIImage(named: "unliked_icon")
            }
        }
    }
    var post: Post?
    var pageIndex: Int!
    var accessToken: String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupUI() {
        self.usernameLabel.text = self.post!.username
        if let profileImgUrl = NSURL(string: self.post!.profileImage!) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                dispatch_async(dispatch_get_main_queue()) {
            self.profileImage.hnk_setImageFromURL(profileImgUrl)
                }}
        }
        if let imageUrl = NSURL(string: self.post!.image!) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                dispatch_async(dispatch_get_main_queue()) {
            self.image.hnk_setImageFromURL(imageUrl)
                }}
        }
        self.captionText.text = self.post!.text
        self.likesCountLabel.text = "\(self.post!.likesCount!) Likes"
        self.liked = self.post!.liked
    }
    
    // MARK: - Navigation
    
    func imageTap(gestureRecognizer: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("profile", sender: self)
    }
    
    func likeHandler(gestureRecognizer: UITapGestureRecognizer) {
        if self.liked == true {
            InstagramAPI.sharedInstance.removeLikeMedia(accessToken!, mediaId: self.post!.mediaId!)
        } else {
            InstagramAPI.sharedInstance.setLikeMedia(accessToken!, mediaId: self.post!.mediaId!)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profile" {
            if let pvc = segue.destinationViewController as? ProfileViewController {
                pvc.userId = self.post!.userId
                pvc.username = self.post!.username
                pvc.profileImgUrl = self.post!.profileImage
                pvc.pvcIndex = self.pageIndex
                pvc.accessToken = self.accessToken
            }
        }
    }
    
}
