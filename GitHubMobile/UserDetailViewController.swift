//
//  UserDetailViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/24/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {

    var reverseOrigin : CGRect?
    var userImage : UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
