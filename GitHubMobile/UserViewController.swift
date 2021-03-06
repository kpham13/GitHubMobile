//
//  UserViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/23/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    var users : [Users]?
    var origin : CGRect?
    var networkController : GitHubService!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVC()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.navigationController?.delegate = appDelegate
        self.networkController = appDelegate.networkController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.users == nil {
            return 0
        } else {
            return self.users!.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : UserCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("USER_CELL", forIndexPath: indexPath) as UserCollectionViewCell
        
        var currentTag = cell.tag + 1
        cell.tag = currentTag
            
        let user = self.users?[indexPath.row]
        cell.imageView.backgroundColor = UIColor.whiteColor()
        cell.loginLabel.text = user!.login
            
        // Download user image
        self.networkController.downloadUserImage(user!, completionHandler: { (image) -> (Void) in
            let cellForImage = self.collectionView.cellForItemAtIndexPath(indexPath) as UserCollectionViewCell?
            if cell.tag == currentTag {
                cellForImage?.imageView.image = image
            }
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER_VIEW", forIndexPath: indexPath) as UserHeaderView
        reusableView = headerView
        
        return reusableView
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let user = self.users?[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("USER_DETAIL_VIEW") as UserDetailViewController
        
        viewController.selectedUser = user?
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return text.validate()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        var searchText = searchBar.text
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        
        self.networkController.userSearch(searchText, completionHandler: { (errorDescription, users) -> (Void) in
            if errorDescription != nil {
                println("Bad")
            } else {
                self.users = users
                println(self.users!.count)
                self.collectionView.reloadData()
            }
        })
        
    }
    
    // MARK: - viewDidLoad
    
    func setupVC() {
        // Registering Collection View Cell Nib file
        self.collectionView.registerNib(UINib(nibName: "UserCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "USER_CELL")
    }
    
    // Adjust collection view cell heights based on device: iPhone 5: 78x78, iPhone6:
    
}