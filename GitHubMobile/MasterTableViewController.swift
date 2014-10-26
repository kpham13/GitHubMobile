//
//  MasterTableViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/21/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class MasterTableViewController: UITableViewController {

    var clientID : String?
    var clientSecret : String?
    var networkController : GitHubService!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVC()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        
        // 6. Authentication check
        if self.networkController.isAuthenticated() == false {
            println("Not authenticated...")
            self.networkController.requestOAuthAccess(self.clientID!, secret: self.clientSecret!)
        } else {
            println("Already authenticated.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - viewDidLoad
    
    func setupVC() {
        let tokens = Tokens()

        self.clientID = tokens.clientID
        self.clientSecret = tokens.clientSecret
    }

}
