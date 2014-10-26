//
//  HideUserAnimator.swift
//  GitHubMobile
//
//  Created by Kevin Pham on 10/24/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

class HideUserAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 1.0
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // References for origin and destination view controllers
        let originViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UserDetailViewController
        let destinationViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as UserViewController
        
        // Container view from context
        let containerView = transitionContext.containerView()
        //containerView.backgroundColor = UIColor.whiteColor()
        
        if let collectionView = destinationViewController.collectionView {
            let originIndexPath = collectionView.indexPathsForSelectedItems()?.first as NSIndexPath
            let attributes = collectionView.layoutAttributesForItemAtIndexPath(originIndexPath)
            
            let cell = collectionView.cellForItemAtIndexPath(originIndexPath) as UserCollectionViewCell
            let destinationRect = destinationViewController.view.convertRect(attributes!.frame, fromView: collectionView)
            
            // Snapshot the cell's image view
            let insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 5.0, right: 0.0)
            let snapshotView = originViewController.imageView
            let snapshot = snapshotView.resizableSnapshotViewFromRect(snapshotView.bounds, afterScreenUpdates: false, withCapInsets: insets)
            
            snapshot.frame = containerView.convertRect(snapshot.frame, fromView: snapshotView)
            
            // Hide when transitioning...
            destinationViewController.view.alpha = 0.0
            cell.alpha = 0.0
            
            containerView.addSubview(snapshot)
            containerView.insertSubview(destinationViewController.view, belowSubview: originViewController.view)
            //originViewController.imageView.removeFromSuperview()
            
            UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: nil, animations: { () -> Void in
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3, animations: { () -> Void in
                    originViewController.view.alpha = 0.0
                })
                UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.3, animations: { () -> Void in
                    snapshot.frame = destinationRect
                })
                UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.3, animations: { () -> Void in
                    destinationViewController.view.alpha = 1.0
                    cell.alpha = 1.0
                })
                }, completion: { (finished) -> Void in
                    // Removing snapshot from container view
                    snapshot.removeFromSuperview()
                    transitionContext.completeTransition(finished)
            })
        }
    }

}