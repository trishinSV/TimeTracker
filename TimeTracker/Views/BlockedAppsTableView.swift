//
//  BlockedAppsTableView.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 06.01.2026.
//

import SwiftUI

struct BlockedAppsTableView: View {

    @Binding var blockedApps: [MacApplication]

    @Binding var isBlockingEnabled: Bool
    var pausedApps: Set<String>
    var onAppSelected: ((MacApplication) -> Void)

    @State
    private var searchText = ""

    private var filteredApps: [MacApplication] {
        searchText.isEmpty ?
        blockedApps :
        blockedApps.filter { string in
            string.name.localizedCaseInsensitiveContains(searchText)
        }
    }

        // Группировка результатов поиска
    private var searchResults: [(section: String, items: [MacApplication])] {
        searchText.isEmpty ?
        [("Все элементы", blockedApps)] :
        [("Результаты поиска", filteredApps)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            table
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack {
            Toggle("Включить блокировку", isOn: $isBlockingEnabled)
                .toggleStyle(.switch)
                .help("Enable or disable app blocking")

            Text("Выбранные приложения:")
                .font(.headline)

            Spacer()

                // Быстрый поиск по выбранным
            SearchBar(
                placeholder: "Поиск в выбранных...",
                text: $searchText,
                onClear: { searchText = "" }
            )
            .frame(width: 200)
        }
    }

    private var table: some View {
        List {
            ForEach(searchResults, id: \.section) { section in
                if !section.items.isEmpty {
                    Section(section.section) {
                        ForEach(section.items, id: \.self) { app in
                            AppRowView(
                                app: app,
                                isPaused: pausedApps.contains(app.bundleIdentifier),
                                onDelete: { removeApp(app.bundleIdentifier) },
                                onSelect: { onAppSelected(app) }
                            )
                        }
                    }
                }
            }
        }
    }

    private func removeApp(_ bundleIdentifier: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            blockedApps.removeAll { $0.bundleIdentifier == bundleIdentifier }
        }
    }
}
