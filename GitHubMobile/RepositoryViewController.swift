//
//  RepositoryViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/20/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class RepositoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var repos : [Repositories]?
    var networkController : GitHubService!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 8. Registering Table View Cell Nib file
        self.tableView.registerNib(UINib(nibName: "RepoTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "REPO_CELL")
        
        // 9. Dynamic Cell Height
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.repos == nil {
            return 0
        } else {
            return self.repos!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("REPO_CELL", forIndexPath: indexPath) as RepoTableViewCell
        
        let repo = self.repos?[indexPath.row]
        
        cell.fullNameLabel.text = repo?.fullName
        cell.descriptionLabel.text = repo?.description
        cell.languageLabel.text = repo?.language
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    // MARK: - Search Bar Delegate
    // 11
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return text.validate()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var searchText = searchBar.text
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        
        self.networkController.repoSearch(searchText, completionHandler: { (errorDescription, repos) -> (Void) in
            if errorDescription != nil {
                // Alert the user that something went wrong here or log errors.
                println("Bad")
            } else {
                self.repos = repos
                println(self.repos!.count)
                self.tableView.reloadData()
            }
        })

    }
    
}