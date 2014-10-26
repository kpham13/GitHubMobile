//
//  RepositoryWebViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/25/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit
import WebKit

class RepositoryWebViewController: UIViewController {

    var repoURL : String?
    let webView = WKWebView()

    override func loadView() {
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: self.repoURL!)!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
