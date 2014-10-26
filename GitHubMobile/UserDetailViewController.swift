//
//  UserDetailViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/24/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {

    var selectedUser : Users?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var htmlLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - viewDidLoad
    
    func setupVC() {
        self.imageView.image = self.selectedUser?.avatarImage
        self.loginLabel.text = self.selectedUser?.login
        self.htmlLabel.text = self.selectedUser?.htmlURL
    }

}
