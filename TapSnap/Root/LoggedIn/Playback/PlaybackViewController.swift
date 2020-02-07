//
//  MessageViewController.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class PlaybackViewController: UIViewController {
    
    private let backButton = UIButton(type: .custom)
    private let groupNameButton = UIButton(type: .custom)
    private let nextButton = UIButton(type: .custom)
    var swipeableView: ZLSwipeableView = ZLSwipeableView()
    var tapsRemaining = 8
    
    init() {
        swipeableView.translatesAutoresizingMaskIntoConstraints = false
        swipeableView.allowedDirection = .All
        
        backButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        backButton.floatButton()
        
        groupNameButton.setTitle("Pop That", for: .normal)
        groupNameButton.floatButton()
        
        nextButton.setImage(UIImage(systemName: "forward.end"), for: .normal)
        nextButton.floatButton()
        
        super.init(nibName: nil, bundle: nil)
        do {
            configureViews()
            configureButtonTargets()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        swipeableView.didDisappear = { view in
            if self.tapsRemaining <= 0 {
                self.dismiss(animated: false, completion: nil)
            }
            self.tapsRemaining -= 1
        }
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        
        navigationItem.titleView = groupNameButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextButton)
        
        view.addSubview(swipeableView)
        swipeableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        swipeableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        swipeableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        swipeableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    // MARK: - Configure Button Targets
    
    private func configureButtonTargets() {
        backButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        groupNameButton.addTarget(self, action: #selector(groupSettingsAction), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
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
