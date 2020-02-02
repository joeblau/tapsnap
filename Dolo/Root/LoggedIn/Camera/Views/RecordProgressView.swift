//
//  RecordProgressView.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit

class RecordProgressView: UIView {

    let progressView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    var widthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .blue
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        addSubview(progressView)
        progressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        widthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0.0)
        widthConstraint.isActive = true
    }
    
    public func staart() {
        UIView.animate(withDuration: 10) {
            self.widthConstraint.constant = UIScreen.main.bounds.width
        }
    }
    
    public func reset() {
        UIView.animate(withDuration: 0.3) {
            self.widthConstraint.constant = 0
        }
    }
    
}
