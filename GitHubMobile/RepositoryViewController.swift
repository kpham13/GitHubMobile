//
//  RepositoryViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/20/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class RepositoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    // MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("REPO_CELL", forIndexPath: indexPath) as UITableViewCell
        
        let repo = self.repos?[indexPath.row]
        cell.textLabel.text = repo?.description
        
        return cell
    }
    
}
