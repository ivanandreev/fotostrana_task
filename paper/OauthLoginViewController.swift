//
//  OauthLoginViewController.swift
//  Paper
//
//  Created by Иван Андреев on 27.12.15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import UIKit
import OAuthSwift

class OauthLoginViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var targetURL: NSURL = NSURL()
    let instagram = InstagramAPI.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://ya.ru")!))
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func handle(url: NSURL) {
//        targetURL = url
//        super.handle(url)
//        loadAddressURL()
//    }
    
    func loadAddressURL() {
        let req = NSURLRequest(URL: targetURL)
        self.webView.loadRequest(req)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
