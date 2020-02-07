//
//  MusicPlaybackView.swift
//  Dolo
//
//  Created by Joe Blau on 2/4/20.
//  Copyright © 2020 Joe Blau. All rights reserved.
//

import UIKit
import MediaPlayer

final class MusicPlaybackView: UIView {
    
    private let intrinsicHeight: CGFloat
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    private let musicTableView = UITableView(frame: .zero, style: .insetGrouped)
    
    init(height: CGFloat) {
        musicTableView.translatesAutoresizingMaskIntoConstraints = false
        musicTableView.alwaysBounceVertical = false
        musicTableView.estimatedRowHeight = 54
        musicTableView.rowHeight = UITableView.automaticDimension
        musicTableView.backgroundColor = .clear
        musicTableView.allowsSelection = false
        
        intrinsicHeight = height - 48.0
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        do {
            musicTableView.register(SyncTableViewCell.self, forCellReuseIdentifier: SyncTableViewCell.id)
            musicTableView.register(NowPlayingPreviewTableViewCell.self, forCellReuseIdentifier: NowPlayingPreviewTableViewCell.id)
            musicTableView.dataSource = self
        }
        
        do {
            configureButtonTargets()
            configureViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Button Targets
    
    private func configureButtonTargets() {}
    
    // MARK: - Configure Views
    
    private func configureViews() {
        addSubview(musicTableView)
        musicTableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        musicTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        musicTableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        musicTableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIWindow().screen.bounds.width,
                      height: intrinsicHeight)
    }
    
    // MARK: - Actions
    
}

extension MusicPlaybackView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
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
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "Play song from current position when video starts"
        default: return nil
        }
    }
    
}
