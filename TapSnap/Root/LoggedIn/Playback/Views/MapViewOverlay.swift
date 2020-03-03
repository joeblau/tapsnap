// MapViewOverlay.swift
// Copyright (c) 2020 Tapsnap, LLC

import Combine
import Contacts
import CoreLocation
import UIKit

final class MapViewOverlay: UIView {
    var cancellables = Set<AnyCancellable>()
    private let kButtonSize: CGFloat = 48
    private let kButtonPadding: CGFloat = 8
    
    private lazy var timeDistanceLocation: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.6
        l.numberOfLines = 0
        l.floatLabel()
        return l
    }()
    
    private lazy var toggle3DButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "view.3d"), for: .normal)
        b.accessibilityIdentifier = "3d"
        b.segmentButton(position: .top)
        return b
    }()
    
    private lazy var toggleAnnotationsButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "person.2"), for: .normal)
        b.accessibilityIdentifier = "all"
        b.segmentButton(position: .bottom)
        return b
    }()
    
    private lazy var mapActionsStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [toggle3DButton, toggleAnnotationsButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = UIStackView.spacingUseSystem
        return sv
    }()
    
    
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        bootstrap()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(playbackMetadata: PlaybackMetadata?) {
        
        let attributedMetadataString = NSMutableAttributedString()
        if let formattedAddress = playbackMetadata?.address {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "mappin.and.ellipse",
                                            withConfiguration: UIImage.SymbolConfiguration(scale: .small))?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            
            attributedMetadataString.append(NSAttributedString(attachment: imageAttachment))
            attributedMetadataString.append(NSAttributedString(string: " \(formattedAddress)\n"))
        }
        
        if let myLocation = Current.currentLocationSubject.value,
            let theirLocation = playbackMetadata?.location {
            let distance = myLocation.distance(from: theirLocation)
            
            let formattedDistance = Current.formatter.distance.string(fromDistance: distance)
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "map",
                                            withConfiguration: UIImage.SymbolConfiguration(scale: .small))?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            
            attributedMetadataString.append(NSAttributedString(attachment: imageAttachment))
            attributedMetadataString.append(NSAttributedString(string: " \(formattedDistance) away\n"))
        }
        
        
        if let sentDate = playbackMetadata?.date {
            let formattedTimeAgo = Current.formatter.timeAgo.localizedString(for: sentDate, relativeTo: Date())
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "clock",
                                            withConfiguration: UIImage.SymbolConfiguration(scale: .small))?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            
            attributedMetadataString.append(NSAttributedString(attachment: imageAttachment))
            attributedMetadataString.append(NSAttributedString(string: " \(formattedTimeAgo)\n"))
        }
        
        timeDistanceLocation.attributedText = attributedMetadataString
    }
    
    // MARK: - Actions
    
    @objc func toggleMapPreviewModeAction(sender: UIButton) {
        switch sender.accessibilityIdentifier {
        case let .some(identifier) where identifier == "2d":
            Current.mapDimensionSubject.send(.two)
        case let .some(identifier) where identifier == "3d":
            Current.mapDimensionSubject.send(.three)
        default: break
        }
    }
    
    @objc func toggleAnnotationsGroupAction(sender: UIButton) {
        switch sender.accessibilityIdentifier {
        case let .some(identifier) where identifier == "them":
            Current.mapAnnotationsSubject.send(.them)
        case let .some(identifier) where identifier == "all":
            Current.mapAnnotationsSubject.send(.all)
        default: break
        }
    }
}

extension MapViewOverlay: ViewBootstrappable {
    func configureViews() {
        toggle3DButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        toggle3DButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        
        toggleAnnotationsButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        toggleAnnotationsButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        
        addSubview(mapActionsStack)
        mapActionsStack.heightAnchor.constraint(greaterThanOrEqualToConstant: kButtonSize).isActive = true
        mapActionsStack.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        mapActionsStack.topAnchor.constraint(equalTo: topAnchor, constant: kButtonPadding).isActive = true
        mapActionsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -kButtonPadding).isActive = true
        
        addSubview(timeDistanceLocation)
        timeDistanceLocation.topAnchor.constraint(equalTo: topAnchor, constant: kButtonPadding).isActive = true
        timeDistanceLocation.heightAnchor.constraint(greaterThanOrEqualToConstant: kButtonSize).isActive = true
        timeDistanceLocation.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kButtonPadding).isActive = true
        timeDistanceLocation.trailingAnchor.constraint(equalTo: mapActionsStack.leadingAnchor, constant: -kButtonPadding).isActive = true
    }
    
    func configureButtonTargets() {
        toggle3DButton.addTarget(self, action: #selector(toggleMapPreviewModeAction), for: .touchUpInside)
        toggleAnnotationsButton.addTarget(self, action: #selector(toggleAnnotationsGroupAction), for: .touchUpInside)
    }
    
    func configureStreams() {
        Current.mapDimensionSubject.sink(receiveValue: { dimension in
            switch dimension {
            case .two:
                self.toggle3DButton.setImage(UIImage(systemName: "view.3d"), for: .normal)
                self.toggle3DButton.accessibilityIdentifier = "3d"
                
            case .three:
                self.toggle3DButton.setImage(UIImage(systemName: "view.2d"), for: .normal)
                self.toggle3DButton.accessibilityIdentifier = "2d"
            }
        })
            .store(in: &cancellables)
        
        Current.mapAnnotationsSubject.sink(receiveValue: { annotationsGroup in
            switch annotationsGroup {
            case .them:
                self.toggle3DButton.isEnabled = true
                self.toggleAnnotationsButton.setImage(UIImage(systemName: "person.2"), for: .normal)
                self.toggleAnnotationsButton.accessibilityIdentifier = "all"
            case .all:
                self.toggle3DButton.isEnabled = false
                self.toggleAnnotationsButton.setImage(UIImage(systemName: "person"), for: .normal)
                self.toggleAnnotationsButton.accessibilityIdentifier = "them"
            }
        })
            .store(in: &cancellables)
    }
}
