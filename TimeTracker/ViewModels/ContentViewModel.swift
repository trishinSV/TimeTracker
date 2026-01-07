//
    //  ContentViewModel.swift
    //  TimeTracker
    //
    //  Created by Сергей Тришин on 06.01.2026.
    //

import Foundation
import ApplicationServices
import AppKit
import Combine

final class ContentViewModel: ObservableObject {

    @Published
    var currentApps: [MacApplication] = []

    @Published
    var blockedApps: [MacApplication] = []

    @Published
    var pausedApps: Set<String> = []

    @Published
    var attemptCounts: [String: Int] = [:]

    @Published
    var isBlockingEnabled: Bool = false

    private let usageTracker: AppUsageTracker
    private let appManager: AppManager
    private let appGuard: AppGuard

    private var cancellables = Set<AnyCancellable>()
    private var attemptCountTimer: Timer?

    private enum Constants {
        static let attemptCountPollingInterval: TimeInterval = 1.0
    }

    init(
        usageTracker: AppUsageTracker = AppUsageTracker(),
        appManager: AppManager = AppManager(),
        appGuard: AppGuard = AppGuard.shared
    ) {

        self.usageTracker = usageTracker
        self.appManager = appManager
        self.appGuard = appGuard

        $blockedApps
            .map { $0.map(\.bundleIdentifier) }
            .sink { [weak self] bundleIdentifiers in
                guard let self = self else { return }
                if self.isBlockingEnabled {
                    self.appGuard.updateBlockedApps(bundleIdentifiers)
                }
                let bundleIdSet = Set(bundleIdentifiers)
                self.pausedApps = self.pausedApps.filter { bundleIdSet.contains($0) }
                self.updateAttemptCountTimer(hasBlockedApps: !bundleIdentifiers.isEmpty)
            }
            .store(in: &cancellables)

        $isBlockingEnabled
            .sink { [weak self] isEnabled in
                guard let self = self else { return }
                if isEnabled {
                    self.start()
                } else {
                    self.stop()
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        attemptCountTimer?.invalidate()
        attemptCountTimer = nil
    }

    func togglePause(for bundleIdentifier: String) {
        if pausedApps.contains(bundleIdentifier) {
            pausedApps.remove(bundleIdentifier)
            appGuard.resumeApp(bundleIdentifier)
        } else {
            pausedApps.insert(bundleIdentifier)
            appGuard.pauseApp(bundleIdentifier)
        }
    }

    func isPaused(for bundleIdentifier: String) -> Bool {
        return pausedApps.contains(bundleIdentifier)
    }

    func startTracking() {
        usageTracker.startTracking()
        currentApps = appManager.getAllApplications()
        updateAttemptCountTimer(hasBlockedApps: !blockedApps.isEmpty)
    }

    func start() {
        appGuard.start(with: blockedApps.map(\.bundleIdentifier))
    }

    func stop() {
        appGuard.stop()
    }

    func usageReport(for app: String) -> String? {
        usageTracker.usageReport(for: app)
    }

    func numberOfAttempts(for app: String) -> String {
        "Number of attempts: \(appGuard.getAttemptCount(for: app))"
    }

    private func updateAttemptCountTimer(hasBlockedApps: Bool) {
        if hasBlockedApps && attemptCountTimer == nil {
            attemptCountTimer = Timer.scheduledTimer(
                withTimeInterval: Constants.attemptCountPollingInterval,
                repeats: true
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAttemptCounts()
            }
            if let timer = attemptCountTimer {
                RunLoop.main.add(timer, forMode: .common)
            }
        } else if !hasBlockedApps && attemptCountTimer != nil {
            attemptCountTimer?.invalidate()
            attemptCountTimer = nil
        }
    }

    private func updateAttemptCounts() {
        guard !blockedApps.isEmpty else { return }

        var newCounts: [String: Int] = [:]
        for app in blockedApps {
            newCounts[app.bundleIdentifier] = appGuard.getAttemptCount(for: app.bundleIdentifier)
        }

        if newCounts != attemptCounts {
            attemptCounts = newCounts
        }
    }
}
