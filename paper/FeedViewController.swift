//
//  MainViewController.swift
//  Paper
//
//  Created by Иван Андреев on 21.12.15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!

    var pvc: UIPageViewController!
    var postArray = [Post]()
    var shouldLogin = true
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var accessToken: String? {
        didSet {
            if accessToken != nil {
                handleRefresh()
                self.navigationController?.navigationBarHidden = false
            } else {
                shouldLogin = true
                self.navigationController?.navigationBarHidden = true
            }
        }
    }
    
    // MARK: - MVC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        if let token = defaults.objectForKey("token") {
            self.accessToken = token as? String
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
        if accessToken == nil {
            if let token = defaults.objectForKey("token") {
                accessToken = token as? String
                shouldLogin = false
            }
        }  else {
            shouldLogin = false
        }
        if self.shouldLogin {
            self.performSegueWithIdentifier("logout", sender: self)
            self.shouldLogin = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleRefresh() {
        if accessToken != nil {
            InstagramAPI.sharedInstance.getSelfFollows(accessToken!, completion: { posts in
                self.postArray = posts as! [Post]
                self.setupUI()
            })
        }
    }
    
    func setupUI() {
        self.pvc = self.storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as? UIPageViewController
        self.pvc.dataSource = self
        let cvc = self.viewControllerAtIndex(0) as ContentViewController
        let viewControllers = NSArray(object: cvc)

        self.pvc.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        self.pvc.view.frame = self.view.bounds
        self.addChildViewController(self.pvc)
        self.view.addSubview(self.pvc.view)
        self.pvc.didMoveToParentViewController(self)
    }
    
    func viewControllerAtIndex(index: Int) -> ContentViewController {
        if((self.postArray.count == 0) || (index >= self.postArray.count )) {
            return ContentViewController()
        }
        let vc: ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        vc.post = self.postArray[index]
        vc.pageIndex = index
        vc.accessToken = self.accessToken!
        
        return vc
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        if(index == NSNotFound) {
            return nil
        }
        index++
        if(index == self.postArray.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index)

    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        if ((index == 0) || index == NSNotFound) {
            return nil
        }
        index--
        
        return self.viewControllerAtIndex(index)
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logout" {
            let _ = segue.destinationViewController as? ViewController
            if self.accessToken != nil {
                self.defaults.removeObjectForKey("token")
                self.accessToken = nil
                self.pvc.dataSource = nil
            }
            
        }
    }

}
