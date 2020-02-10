//
//  RecordProgressView.swift
//  Dolo
//
//  Created by Joe Blau on 2/2/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import Combine

final class RecordProgressView: UIView {

    var progressView: UIView?
    var widthConstraint: NSLayoutConstraint!
    var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        bootstrap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ViewBootstrappable

extension RecordProgressView: ViewBootstrappable {
    internal func configureStreams() {
        Current.mediaActionSubject.sink { action in
            switch action {
            case .captureVideoStart:
                self.widthConstraint.constant = UIScreen.main.bounds.width
                UIView.animate(withDuration: 10.0,
                               delay: 0.0,
                               options: .curveLinear, animations: {
                                self.layoutIfNeeded()
                }, completion: nil)
                
                UIView.animate(withDuration: 1,
                               delay: 0.0,
                               options: [.repeat, .autoreverse],
                               animations: {
                                                            
                                self.progressView?.backgroundColor = UIColor(displayP3Red: 0.500,
                                                                             green: 0.134,
                                                                             blue: 0.115,
                                                                             alpha: 1.0)
                            },
                               completion: nil)
            case .none, .captureVideoEnd:
                self.progressView?.removeFromSuperview()
                self.progressView = UIView()
                self.progressView?.backgroundColor = .systemRed
                self.progressView?.translatesAutoresizingMaskIntoConstraints = false

                self.addSubview(self.progressView!)
                self.progressView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                self.progressView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                self.progressView?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                self.widthConstraint = self.progressView?.widthAnchor.constraint(equalToConstant: 0)
                self.widthConstraint.isActive = true
            default: break
            }
        
        }
        .store(in: &cancellables)
    }
}
