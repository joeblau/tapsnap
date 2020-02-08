//
//  MessageViewController.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

final class PlaybackViewController: UIViewController {
    
    private lazy var backButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        b.floatButton()
        return b
    }()
    private lazy var groupNameButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Pop That", for: .normal)
        b.floatButton()
        return b
    }()
    private lazy var nextButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "forward.end"), for: .normal)
        b.floatButton()
        return b
    }()
    private lazy var swipeableView: ZLSwipeableView = {
        let sv = ZLSwipeableView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.allowedDirection = .All
        return sv
    }()
    var tapsRemaining = 8
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bootstrap()

        swipeableView.didDisappear = { view in
            if self.tapsRemaining <= 0 {
                self.dismiss(animated: false, completion: nil)
            }
            self.tapsRemaining -= 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextTapSnapPlaybackView()
        }
    }
    
    // MARK: - Actions
    
    @objc func dismissAction() {
        Current.presentViewContollersSubject.value = .none
    }
    
    @objc func groupSettingsAction() {}
    
    @objc func nextAction() {
        swipeableView.swipeTopView(inDirection: .Right)
    }
    
    func nextTapSnapPlaybackView() -> UIView? {
        guard self.tapsRemaining > 1 else { return nil }
        return TapSnapPlaybackView()
    }
}


extension PlaybackViewController: ViewBootstrappable {
    internal func configureViews() {
        navigationItem.titleView = groupNameButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextButton)
        
        view.addSubview(swipeableView)
        swipeableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        swipeableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        swipeableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        swipeableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    internal func configureButtonTargets() {
        backButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        groupNameButton.addTarget(self, action: #selector(groupSettingsAction), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
    }
}
