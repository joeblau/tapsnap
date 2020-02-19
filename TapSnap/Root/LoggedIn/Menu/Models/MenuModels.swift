// MenuModels.swift
// Copyright (c) 2020 Tapsnap, LLC

import Foundation

struct SectionItem {
    let menuItems: [MenuItem]
}

struct MenuItem {
    let systemName: String
    let titleText: String
    let subtitleText: String?
    
    init(systemName: String,
         titleText: String,
         subtitleText: String? = nil) {
        self.systemName = systemName
        self.titleText = titleText
        self.subtitleText = subtitleText
    }
}
