// MenuModels.swift
// Copyright (c) 2020 Tapsnap, LLC

import Foundation

struct SectionItem {
    let header: String?
    let footer: String?
    let menuItems: [MenuItem]
    
    init(header: String? = nil, footer: String? = nil, menuItems: [MenuItem]) {
        self.header = header
        self.footer = footer
        self.menuItems = menuItems
    }
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
