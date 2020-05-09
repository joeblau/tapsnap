// MusicPlaybackView.swift
// Copyright (c) 2020 Tapsnap, LLC

import MediaPlayer
import UIKit

final class MusicPlaybackView: UIView {
    private let intrinsicHeight: CGFloat
    private lazy var musicTableView: UITableView = {
        let v = UITableView(frame: .zero, style: .insetGrouped)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alwaysBounceVertical = false
        v.estimatedRowHeight = 54
        v.rowHeight = UITableView.automaticDimension
        v.backgroundColor = .clear
        v.allowsSelection = false
        v.register(SyncTableViewCell.self, forCellReuseIdentifier: SyncTableViewCell.id)
        v.register(NowPlayingPreviewTableViewCell.self, forCellReuseIdentifier: NowPlayingPreviewTableViewCell.id)
        v.dataSource = self
        return v
    }()

    init(height: CGFloat) {
        intrinsicHeight = height - 48.0
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        bootstrap()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIWindow().screen.bounds.width,
               height: intrinsicHeight)
    }
}

// MARK: - ViewBootstrappable

extension MusicPlaybackView: ViewBootstrappable {
    internal func configureViews() {
        addSubview(musicTableView)
        
        NSLayoutConstraint.activate([
            musicTableView.topAnchor.constraint(equalTo: topAnchor),
            musicTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            musicTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            musicTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource

extension MusicPlaybackView: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int { 2 }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let settingCell = tableView.dequeueReusableCell(withIdentifier: SyncTableViewCell.id, for: indexPath) as? SyncTableViewCell else {
                fatalError("Undefined cell")
            }
            settingCell.configure(playbackTime: MPMusicPlayerController.systemMusicPlayer.currentPlaybackTime)
            return settingCell
        case 1:
            guard let mediaCell = tableView.dequeueReusableCell(withIdentifier: NowPlayingPreviewTableViewCell.id, for: indexPath) as? NowPlayingPreviewTableViewCell else {
                fatalError("Undefined cell")
            }
            if let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem {
                mediaCell.configure(image: nowPlaying.artwork?.image(at: CGSize(width: 256, height: 256)),
                                    title: nowPlaying.title,
                                    artist: nowPlaying.artist)
            }
            return mediaCell

        default: break
        }
        fatalError("Undefined cell")
    }

    func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "Play song from current position when video starts"
        default: return nil
        }
    }
}
