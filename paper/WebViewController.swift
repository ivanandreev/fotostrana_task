//
//  WebViewController.swift
//  Paper
//
//  Created by Иван Андреев on 20.12.15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import UIKit
import OAuthSwift

class WebViewController: OAuthWebViewController {

    var targetURL: NSURL = NSURL()
    var webView: UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.webView.backgroundColor = UIColor.whiteColor()
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        self.webView.frame = self.view.bounds
        self.webView.delegate = self
        self.view.addSubview(self.webView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func handle(url: NSURL) {
        targetURL = url
        super.handle(url)        
        loadAddressURL()
    }
    
    func loadAddressURL() {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        let request = NSURLRequest(URL: targetURL, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        self.webView.loadRequest(request)
    }
}

extension WebViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL where (url.scheme == "oauth-swift"){
            self.dismissWebViewController()
        }
        return true
    }
}
