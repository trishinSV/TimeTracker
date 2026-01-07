//
//  AppUsageTracker.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 06.01.2026.
//

import Cocoa
import AppKit

final class AppUsageTracker: AnyObject {
    private var usageData: [String: AppUsage] = [:]
    private var timer: Timer?
    private var currentApp: String = ""

    struct AppUsage {
        var totalTime: TimeInterval = 0
        var sessions: Int = 0
        var lastActive: Date?
    }

    func startTracking() {
        if let app = NSWorkspace.shared.frontmostApplication,
           let bundleId = app.bundleIdentifier {
            currentApp = bundleId
            usageData[bundleId] = AppUsage(sessions: 1, lastActive: Date())
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateUsage()
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.appSwitched(notification)
        }
    }

    func printUsageReport() {
        print("\n📊 App Usage Report:")
        for (bundleId, usage) in usageData.sorted(by: { $0.value.totalTime > $1.value.totalTime }) {
            let minutes = Int(usage.totalTime / 60)
            print("  • \(bundleId): \(minutes) minutes, \(usage.sessions) sessions")
        }
    }

    func usageReport(for app: String) -> String? {
        if let usage = usageData[app],
           let date = usage.lastActive {
            print("\n📊 App Usage Report:")
            let minutes = Int(usage.totalTime / 60)
            return "Время использования \(minutes) минут \( Int(usage.totalTime) % 60) секунд\nКоличество сессий: \(usage.sessions)\nДата последнего открытия \(date)"
        } else {
            return nil
        }
    }

    private func updateUsage() {
        guard !currentApp.isEmpty,
              var usage = usageData[currentApp],
              let lastActive = usage.lastActive else {
            return
        }

        usage.totalTime += Date().timeIntervalSince(lastActive)
        usage.lastActive = Date()
        usageData[currentApp] = usage
    }

    private func appSwitched(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleId = app.bundleIdentifier else {
            return
        }

        if !currentApp.isEmpty, var usage = usageData[currentApp] {
            if let lastActive = usage.lastActive {
                usage.totalTime += Date().timeIntervalSince(lastActive)
            }
            usageData[currentApp] = usage
        }

        currentApp = bundleId
        if usageData[bundleId] == nil {
            usageData[bundleId] = AppUsage(sessions: 1, lastActive: Date())
        } else {
            usageData[bundleId]?.sessions += 1
            usageData[bundleId]?.lastActive = Date()
        }

        print("🔁 Switched to: \(bundleId) - \(app.localizedName ?? "Unknown")")
    }
}
