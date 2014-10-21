//
//  SplitContainerViewController.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/20/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

// 1
class SplitContainerViewController: UIViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2
        let splitVC = self.childViewControllers[0] as UISplitViewController
        splitVC.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 3
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return true
    }

}
