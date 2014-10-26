//
//  ShowUserAnimator.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/24/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class ShowUserAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration = 1.0
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) /*-> NSTimeInterval */{
        // References for origin and destination view controllers
        let originViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UserViewController
        let destinationViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as UserDetailViewController
// check destination VC
        
        // Container view from context
        let containerView = transitionContext.containerView()
        containerView.backgroundColor = UIColor.whiteColor()
        
        if let collectionView = originViewController.collectionView {
            let originIndexPath = collectionView.indexPathsForSelectedItems()?.first as NSIndexPath
            let attributes = collectionView.layoutAttributesForItemAtIndexPath(originIndexPath)
            
            let cell = collectionView.cellForItemAtIndexPath(originIndexPath) as UserCollectionViewCell
            let originRect = originViewController.view.convertRect(attributes!.frame, fromView: collectionView)
            
            // Snapshot the cell's image view
            let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            let snapshot = cell.imageView.resizableSnapshotViewFromRect(cell.imageView.bounds, afterScreenUpdates: false, withCapInsets: insets)
            
            snapshot.frame = originRect
            
            // Hide the destination view controller
            destinationViewController.view.alpha = 0.0
            
            containerView.addSubview(snapshot)
            containerView.addSubview(destinationViewController.view)
            
            // Hide the cell when transitioning
            cell.alpha = 0.0
            
            UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: nil, animations: { () -> Void in
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3, animations: { () -> Void in
                    originViewController.view.alpha = 0.0
                })
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.6, animations: { () -> Void in
                    snapshot.frame = destinationViewController.imageView.frame
                })
                UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.3, animations: { () -> Void in
                    destinationViewController.view.alpha = 1.0
                })
                }, completion: { (finished) -> Void in
                    // Removing snapshot from container view
                    snapshot.removeFromSuperview()
                    transitionContext.completeTransition(finished)
            })
        }
    }
}
