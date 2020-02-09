//
//  TransitionDelegate.swift
//  Tapsnap
//
//  Created by Joe Blau on 2/8/20.
//

import UIKit

public struct Movement {
    public let location: CGPoint
    public let translation: CGPoint
    public let velocity: CGPoint
}

class SwippableTransitionController: NSObject {
    static fileprivate let anchorViewWidth = CGFloat(1000)
    fileprivate var anchorView = UIView(frame: CGRect(x: -373, y: -466.2, width: anchorViewWidth, height: anchorViewWidth))
    fileprivate var animator: UIDynamicAnimator!
    fileprivate var viewToAnchorViewAttachmentBehavior: UIAttachmentBehavior!
    fileprivate var pushBehavior: UIPushBehavior!
    
    // MARK: - Interactive
//    fileprivate lazy var panGestureRecoginzer: UIPanGestureRecognizer = {
//        let gr =  UIPanGestureRecognizer(target: self, action: #selector(handlePanAction(_:)))
//        return gr
//    }()
//    private let containerView: UIView
    
//    init(viewController: UIViewController) {
//        self.containerView = viewController.view
//        super.init()
//        viewController.view.addGestureRecognizer(panGestureRecoginzer)

//    }
    
    // MARK: - Actions
//    @objc func handlePanAction(_ recognizer: UIPanGestureRecognizer) {
//        let translation = recognizer.translation(in: containerView)
//        let location = recognizer.location(in: containerView)
//        let velocity = recognizer.velocity(in: containerView)
//        let movement = Movement(location: location, translation: translation, velocity: velocity)
//        
//        switch recognizer.state {
//        case .began:
//            print("being")
//            guard case .snapping(_) = state else { return }
//            state = .moving(location)
//            swipeableView.didStart?(view, location)
//        case .changed:
//            print("changed")
//            guard case .moving(_) = state else { return }
//            state = .moving(location)
//            swipeableView.swiping?(view, location, translation)
//        case .ended, .cancelled:
//            print("end")
//            guard case .moving(_) = state else { return }
//            if swipeableView.shouldSwipeView(view, movement, swipeableView) {
//                let directionVector = CGVector(point: translation.normalized * max(velocity.magnitude, swipeableView.minVelocityInPointPerSecond))
//                state = .swiping(location, directionVector)
//                swipeableView.swipeView(view, location: location, directionVector: directionVector)
//            } else {
//                state = snappingStateAtContainerCenter()
//                swipeableView.didCancel?(view)
//            }
//            swipeableView.didEnd?(view, location)
//        default:
//            break
//        }
//    }
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
        return 0.7
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
        viewToAnchorViewAttachmentBehavior.damping = 50
        viewToAnchorViewAttachmentBehavior.length = 0
        animator.addBehavior(viewToAnchorViewAttachmentBehavior!)

        pushBehavior = UIPushBehavior(items: [anchorView], mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 2000, dy: 0)
        animator.addBehavior(pushBehavior)

        let duration = transitionDuration(using: transitionContext)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}
