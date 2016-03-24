//
//  ProfileViewController.swift
//  Paper
//
//  Created by Иван Андреев on 28.12.15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
        
    @IBOutlet var profileImg: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var cellView: UICollectionView!
    
    var userId: String?
    var username: String?
    var profileImgUrl: String?
    var pvcIndex: Int?
    var accessToken: String?
    
    private let reuseIdentifier = "CellItem";
    
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameLabel.text = self.username
        self.cellView.collectionViewLayout = ImageFlowLayout()
        
        if let url = NSURL(string: self.profileImgUrl!) {
            self.profileImg.hnk_setImageFromURL(url)
        }
        
        InstagramAPI.sharedInstance.getUserMediaRecent(self.accessToken!, userid: userId!, count: 15, completion: {result in
            if let array = result as? [Post] {
                self.posts.appendContentsOf(array)
                self.cellView.dataSource = self
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoViewCell
        cell.backgroundColor = UIColor.grayColor()
        if let url = NSURL(string: posts[indexPath.row].thumbnailURL!) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                dispatch_async(dispatch_get_main_queue()) {
            cell.imageView.hnk_setImageFromURL(url)
                }}
        }
        return cell
    }
}
