// RecordProgressView.swift
// Copyright (c) 2020 Tapsnap, LLC

import Combine
import UIKit

final class RecordProgressView: UIView {
    lazy var progressView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemRed
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    var widthConstraint: NSLayoutConstraint?
    var cancellables = Set<AnyCancellable>()

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewBootstrappable

extension RecordProgressView: ViewBootstrappable {
    func configureViews() {
        addSubview(progressView)
        progressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        widthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        widthConstraint?.isActive = true
    }

    internal func configureStreams() {
        Current.mediaActionSubject.sink { action in
            switch action {
            case .captureVideoStart:
                self.widthConstraint?.constant = UIScreen.main.bounds.width
                UIView.animate(withDuration: 10.0,
                               delay: 0.0,
                               options: .curveLinear,
                               animations: {
                                   self.layoutIfNeeded()
                               },
                               completion: { _ in
                                   guard !(Current.mediaActionSubject.value == .captureVideoEnd) else { return }
                                   Current.mediaActionSubject.send(.captureVideoEnd)
                                })

                UIView.animate(withDuration: 1,
                               delay: 0.0,
                               options: [.repeat, .autoreverse],
                               animations: {
                                   self.progressView.backgroundColor = UIColor(displayP3Red: 0.500,
                                                                               green: 0.134,
                                                                               blue: 0.115,
                                                                               alpha: 1.0)
                               },
                               completion: nil)
            case .none, .captureVideoEnd:
                self.progressView.layer.removeAllAnimations()
                self.progressView.backgroundColor = .systemRed
                self.widthConstraint?.constant = 0
            default: break
            }
        }
        .store(in: &cancellables)
    }
}
