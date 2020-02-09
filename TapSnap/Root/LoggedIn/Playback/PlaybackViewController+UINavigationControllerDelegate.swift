//
//  PlaybackViewController+UIViewControllerTransitioningDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/8/20.
//

import UIKit

extension PlaybackViewController: UINavigationControllerDelegate {
  
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SwippableTransitionController()
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
