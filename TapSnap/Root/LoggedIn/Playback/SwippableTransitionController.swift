//
//  TransitionDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/8/20.
//

import UIKit

class SwippableTransitionController: NSObject {
    static fileprivate let anchorViewWidth = CGFloat(1000)
    fileprivate var anchorView = UIView(frame: CGRect(x: -100, y: -1200, width: anchorViewWidth, height: anchorViewWidth))
    fileprivate var animator: UIDynamicAnimator!
    fileprivate var viewToAnchorViewAttachmentBehavior: UIAttachmentBehavior!
    fileprivate var pushBehavior: UIPushBehavior!
}

// MARK: - UIViewControllerInteractiveTransitioning

extension SwippableTransitionController: UIViewControllerInteractiveTransitioning{
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        //
    }
    
    
}

// MARK: - UIViewControllerAnimatedTransitioning

extension SwippableTransitionController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        anchorView.isHidden = true
        
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        transitionContext.containerView.insertSubview(anchorView, belowSubview: fromVC.view)
        
        let p = fromVC.view.center
        let point = CGPoint(x: 127, y: 33.8)

        animator = UIDynamicAnimator(referenceView: transitionContext.containerView)
        viewToAnchorViewAttachmentBehavior = UIAttachmentBehavior(item: fromVC.view,
                                                                  offsetFromCenter: UIOffset(horizontal: -(p.x - point.x), vertical: -(p.y - point.y)),
                                                                  attachedTo: anchorView,
                                                                  offsetFromCenter: .zero)
        viewToAnchorViewAttachmentBehavior.damping = 200
        viewToAnchorViewAttachmentBehavior.length = 0
        animator.addBehavior(viewToAnchorViewAttachmentBehavior!)

        pushBehavior = UIPushBehavior(items: [anchorView], mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 2000, dy: 0)
        animator.addBehavior(pushBehavior)

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.alpha = 0.3
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}
