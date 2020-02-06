//
//  MessageViewController.swift
//  Dolo
//
//  Created by Joe Blau on 2/3/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class PlaybackViewController: UIViewController {

    var swipeableView: ZLSwipeableView = ZLSwipeableView()

    
    init() {
        swipeableView.translatesAutoresizingMaskIntoConstraints = false
        swipeableView.allowedDirection = .All
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        do {
            configureViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        view.addSubview(swipeableView)
        swipeableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        swipeableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        swipeableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        swipeableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextTapSnapPlaybackView()
        }
    }
    
    func nextTapSnapPlaybackView() -> UIView? {
        return TapSnapPlaybackView()
    }

}
