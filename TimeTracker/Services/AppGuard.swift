//
//  AppGuard.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 06.01.2026.
//

import Foundation
import Cocoa

final class AppGuard: NSObject {
    static let shared = AppGuard()

    private var blockedAppIdentifiers: Set<String> = []
    private var pausedAppIdentifiers: Set<String> = []
    private var attemptCounts: [String: Int] = [:]
    private var isMonitoring = false
    private var timer: Timer?
    private var terminatingApps: Set<String> = []

    private enum Constants {
        static let monitoringInterval: TimeInterval = 2.0
        static let forceKillDelay: TimeInterval = 1.0
        static let terminateDelay: TimeInterval = 0.5
    }

    private override init() {}

    func start(with blockedApps: [String]) {
        blockedAppIdentifiers = Set(blockedApps)

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(appWillLaunch(_:)),
            name: NSWorkspace.willLaunchApplicationNotification,
            object: nil
        )

        monitorRunningApps()

        isMonitoring = true
        print("🔒 AppGuard activated")
    }

    @objc private func appWillLaunch(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleId = app.bundleIdentifier else {
            return
        }

        if blockedAppIdentifiers.contains(bundleId) && !pausedAppIdentifiers.contains(bundleId) {
            guard !terminatingApps.contains(bundleId) else { return }
            terminatingApps.insert(bundleId)

            incrementAttemptCount(for: bundleId)
            print("🚫 Blocking launch of: \(bundleId)")

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let terminated = app.terminate()
                if !terminated {
                    print("⚠️ Failed to terminate \(bundleId)")
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.terminateDelay) { [weak self] in
                    guard let self = self else { return }
                    if app.isFinishedLaunching || !app.isTerminated {
                        app.forceTerminate()
                    }
                    self.terminatingApps.remove(bundleId)
                }
            }
        }
    }

    private func monitorRunningApps() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: Constants.monitoringInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let runningApps = NSWorkspace.shared.runningApplications

            for app in runningApps {
                guard let bundleId = app.bundleIdentifier,
                      self.blockedAppIdentifiers.contains(bundleId),
                      !self.pausedAppIdentifiers.contains(bundleId),
                      !self.terminatingApps.contains(bundleId),
                      app.activationPolicy == .regular else {
                    continue
                }

                self.terminatingApps.insert(bundleId)
                self.incrementAttemptCount(for: bundleId)
                print("⚠️ Blocked app is running: \(bundleId), terminating...")

                let terminated = app.terminate()
                if !terminated {
                    print("⚠️ Failed to terminate \(bundleId)")
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.forceKillDelay) { [weak self] in
                    guard let self = self else { return }
                    if !app.isTerminated {
                        app.forceTerminate()
                    }
                    self.terminatingApps.remove(bundleId)
                }
            }
        }

        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func updateBlockedApps(_ blockedApps: [String]) {
        blockedAppIdentifiers = Set(blockedApps)
        pausedAppIdentifiers = pausedAppIdentifiers.filter { blockedAppIdentifiers.contains($0) }
        attemptCounts = attemptCounts.filter { blockedAppIdentifiers.contains($0.key) }
        monitorRunningApps()
        print("🔄 AppGuard updated with \(blockedAppIdentifiers.count) blocked apps")
    }

    func pauseApp(_ bundleIdentifier: String) {
        if blockedAppIdentifiers.contains(bundleIdentifier) {
            pausedAppIdentifiers.insert(bundleIdentifier)
            print("⏸️ Paused blocking for: \(bundleIdentifier)")
        }
    }

    func resumeApp(_ bundleIdentifier: String) {
        pausedAppIdentifiers.remove(bundleIdentifier)
        print("▶️ Resumed blocking for: \(bundleIdentifier)")
    }

    func isAppPaused(_ bundleIdentifier: String) -> Bool {
        return pausedAppIdentifiers.contains(bundleIdentifier)
    }

    private func incrementAttemptCount(for bundleIdentifier: String) {
        attemptCounts[bundleIdentifier, default: 0] += 1
    }

    func getAttemptCount(for bundleIdentifier: String) -> Int {
        attemptCounts[bundleIdentifier] ?? 0
    }

    func stop() {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        isMonitoring = false
        timer?.invalidate()
        timer = nil
        terminatingApps.removeAll()
        print("🔓 AppGuard deactivated")
    }

    deinit {
        stop()
    }
}
