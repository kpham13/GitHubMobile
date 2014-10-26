//
//  ProfileViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/24/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var profileUser : Users?
    var networkController : GitHubService!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var repoCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        
        self.networkController.fetchUserProfile( { (errorDescription, user) -> (Void) in
            if errorDescription != nil {
                println("Bad")
            } else {
                self.profileUser = user
                println(self.profileUser!.fullName!)
                println(self.profileUser!.login)
                println(self.profileUser!.company!)
                println(self.profileUser!.location!)
                println(self.profileUser!.publicRepos!)
                println(self.profileUser!.email!)
                
                self.nameTextField.text = self.profileUser!.fullName!
                self.emailTextField.text = self.profileUser!.email!
                self.companyTextField.text = self.profileUser!.company!
                self.locationTextField.text = self.profileUser!.location!
                var repoCount = self.profileUser!.publicRepos!
                self.repoCountLabel.text = String(repoCount)
                
                self.networkController.downloadUserImage(self.profileUser!, completionHandler: { (image) -> (Void) in
                    self.imageView.image = image
                })


            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
