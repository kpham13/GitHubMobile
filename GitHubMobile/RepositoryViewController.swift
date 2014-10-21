//
//  RepositoryViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/20/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class RepositoryViewController: UIViewController {
    
    var repos : [Repositories]?
    let networkController = GitHubService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.networkController.dataTask { (errorDescription, repos) -> (Void) in
            if errorDescription != nil {
                // Alert the user that something went wrong here or log errors.
                println("Bad")
            } else {
                self.repos = repos
                println(self.repos!.count)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: -
    
}
