//
//  AppManager.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 07.01.2026.
//

import Foundation
import AppKit

final class AppManager: AnyObject {
        // Получить все приложения
    func getAllApplications() -> [MacApplication] {
        var applications: [MacApplication] = []

            // Директории для поиска
        let searchPaths = [
            "/Applications",
            "\(NSHomeDirectory())/Applications"
        ]

            // Список запущенных приложений
        let runningApps = NSWorkspace.shared.runningApplications
        let runningBundleIds = Set(runningApps.compactMap { $0.bundleIdentifier })

            // Рекурсивно ищем .app файлы
        for path in searchPaths {
            if let urls = findApplicationURLs(in: path) {
                for url in urls {
                    if let app = createApplication(from: url, runningBundleIds: runningBundleIds) {
                        applications.append(app)
                    }
                }
            }
        }

        return applications.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

        // Получить только запущенные приложения
    func getRunningApplications() -> [MacApplication] {
        let runningApps = NSWorkspace.shared.runningApplications
        var applications: [MacApplication] = []

        for runningApp in runningApps {
            guard let bundleIdentifier = runningApp.bundleIdentifier,
                  let bundleURL = runningApp.bundleURL,
                  let bundle = Bundle(url: bundleURL) else { continue }

            let name = runningApp.localizedName ??
            bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ??
            bundleURL.deletingPathExtension().lastPathComponent

            let icon = runningApp.icon ?? NSWorkspace.shared.icon(forFile: bundleURL.path)

            let app = MacApplication(
                name: name,
                bundleIdentifier: bundleIdentifier,
                path: bundleURL,
                icon: icon,
                isRunning: true
            )

            applications.append(app)
        }

        return applications
    }

        // Рекурсивный поиск .app файлов
    private func findApplicationURLs(in directory: String) -> [URL]? {
        guard FileManager.default.fileExists(atPath: directory) else { return nil }

        var urls: [URL] = []
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]

        if let enumerator = FileManager.default.enumerator(
            at: URL(fileURLWithPath: directory),
            includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey],
            options: options
        ) {
            for case let url as URL in enumerator {
                if url.pathExtension == "app" && isApplicationBundle(url) {
                    urls.append(url)
                    enumerator.skipDescendants() // Не ищем внутри .app пакета
                }
            }
        }

        return urls
    }

        // Проверяем, что это действительно приложение
    private func isApplicationBundle(_ url: URL) -> Bool {
        let plistPath = url.appendingPathComponent("Contents/Info.plist").path
        return FileManager.default.fileExists(atPath: plistPath)
    }

        // Создаем объект приложения
    private func createApplication(from url: URL, runningBundleIds: Set<String>) -> MacApplication? {
        guard let bundle = Bundle(url: url) else { return nil }

        let bundleIdentifier = bundle.bundleIdentifier ?? "unknown.\(UUID().uuidString)"

            // Получаем имя приложения
        let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        url.deletingPathExtension().lastPathComponent

            // Получаем иконку
        let icon = getIcon(for: bundle, or: url)

            // Проверяем, запущено ли приложение
        let isRunning = runningBundleIds.contains(bundleIdentifier)

        return MacApplication(
            name: name,
            bundleIdentifier: bundleIdentifier,
            path: url,
            icon: icon,
            isRunning: isRunning
        )
    }

        // Получаем иконку приложения
    private func getIcon(for bundle: Bundle, or url: URL) -> NSImage? {
            // Сначала пробуем получить иконку из Info.plist
        if let iconFiles = bundle.object(forInfoDictionaryKey: "CFBundleIconFiles") as? [String],
           let firstIcon = iconFiles.first,
           let iconPath = bundle.pathForImageResource(firstIcon) {
            return NSImage(contentsOfFile: iconPath)
        }

            // Пробуем стандартные имена иконок
        let iconNames = ["AppIcon", "NSApplicationIcon", "Icon"]
        for iconName in iconNames {
            if let iconPath = bundle.pathForImageResource(iconName) {
                return NSImage(contentsOfFile: iconPath)
            }
        }

            // Используем системный метод как запасной вариант
        return NSWorkspace.shared.icon(forFile: url.path)
    }
}
