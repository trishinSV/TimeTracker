//
//  MacApplication.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 07.01.2026.
//

import SwiftUI

struct MacApplication: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let path: URL
    let icon: NSImage?
    let isRunning: Bool

    static func == (lhs: MacApplication, rhs: MacApplication) -> Bool {
        lhs.bundleIdentifier == rhs.bundleIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
    }
}
