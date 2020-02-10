// MusicPlaybackView.swift
// Copyright (c) 2020 Tapsnap, LLC

import MediaPlayer
import UIKit

final class MusicPlaybackView: UIView {
    private let intrinsicHeight: CGFloat
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private lazy var musicTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.alwaysBounceVertical = false
        tv.estimatedRowHeight = 54
        tv.rowHeight = UITableView.automaticDimension
        tv.backgroundColor = .clear
        tv.allowsSelection = false
        tv.register(SyncTableViewCell.self, forCellReuseIdentifier: SyncTableViewCell.id)
        tv.register(NowPlayingPreviewTableViewCell.self, forCellReuseIdentifier: NowPlayingPreviewTableViewCell.id)
        tv.dataSource = self
        return tv
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
        musicTableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        musicTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        musicTableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        musicTableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
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
            settingCell.configure(playbackTime: musicPlayer.currentPlaybackTime)
            return settingCell
        case 1:
            guard let mediaCell = tableView.dequeueReusableCell(withIdentifier: NowPlayingPreviewTableViewCell.id, for: indexPath) as? NowPlayingPreviewTableViewCell else {
                fatalError("Undefined cell")
            }
            if let nowPlaying = musicPlayer.nowPlayingItem {
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
