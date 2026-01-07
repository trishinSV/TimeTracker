//
//  AppGuardError.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 07.01.2026.
//

import Foundation

enum AppGuardError: LocalizedError {
    case permissionDenied
    case appNotFound(String)
    case terminationFailed(String)
    case monitoringFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Accessibility permissions are required to block applications"
        case .appNotFound(let bundleId):
            return "Application not found: \(bundleId)"
        case .terminationFailed(let bundleId):
            return "Failed to terminate application: \(bundleId)"
        case .monitoringFailed:
            return "Failed to start monitoring applications"
        }
    }
}
