//
//  ViewController.swift
//  Paper
//
//  Created by Иван Андреев on 20.12.15.
//  Copyright © 2015 IvanAndreev. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: UIViewController {
    
    let instagram = InstagramAPI.sharedInstance
        
    override func viewDidLoad() {
        super.viewDidLoad()
        instagram.oauthswift.authorize_url_handler = get_url_handle()
        instagram.authorize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func get_url_handle() -> OAuthSwiftURLHandlerType {
        let url_handler = createWebViewController()
        return url_handler
    }
    
    func createWebViewController() -> WebViewController {
        let controller = WebViewController()
        return controller
    }
}

