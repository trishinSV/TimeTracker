//
//  AppSelectionModalView.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 06.01.2026.
//

import SwiftUI

struct AppSelectionView: View {

    @Binding
    var selectedApps: [MacApplication]
    @Binding
    var isPresented: Bool

    @State
    private var currentSelections: Set<MacApplication>

    @State
    private var searchText = ""

    private let apps: [MacApplication]

    init(
        apps: [MacApplication],
        selectedApps: Binding<[MacApplication]>,
        isPresented: Binding<Bool>
    ) {
        self.apps = apps
        self._selectedApps = selectedApps
        self._isPresented = isPresented
        self._currentSelections = State(initialValue: Set(selectedApps.wrappedValue))
    }

        // Отфильтрованные приложения на основе поиска
    var filteredApps: [MacApplication] {
        if searchText.isEmpty {
            return apps
        } else {
            return apps.filter { string in
                string.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

        // Группировка результатов поиска
    var searchResults: [(section: String, items: [MacApplication])] {
        if searchText.isEmpty {
                // Без поиска - просто все элементы
            return [("Все элементы", apps)]
        } else {
                // С поиском - показываем только результаты
            return [("Результаты поиска", filteredApps)]
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            header

            Divider()

            if filteredApps.isEmpty && !searchText.isEmpty {
                    // Состояние "ничего не найдено"
                ContentUnavailableView(
                    "Ничего не найдено",
                    systemImage: "magnifyingglass",
                    description: Text("Попробуйте другой запрос")
                )
                .frame(maxHeight: .infinity)
            } else {
                    // Список приложений для выбора
                List {
                    ForEach(searchResults, id: \.section) { section in
                        if !section.items.isEmpty {
                            Section(section.section) {
                                ForEach(section.items, id: \.self) { app in
                                    SelectionRow(
                                        string: app.name,
                                        isSelected: currentSelections.contains(app),
                                        searchText: searchText,
                                        icon: app.icon,
                                        onToggle: { toggleSelection(app) }
                                    )
                                }
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }

            Divider()

            footer
        }
        .padding()
        .frame(minWidth: 500, minHeight: 500)
    }

    private var header: some View {
            // Панель заголовка с поиском
        VStack(spacing: 12) {
            HStack {
                Text("Выберите приложения")
                    .font(.headline)

                Spacer()

                Button("Выбрать все") {
                    currentSelections = Set(apps)
                }

                Button("Выбрать найденные") {
                    if !searchText.isEmpty {
                        currentSelections.formUnion(Set(filteredApps))
                    }
                }
                .disabled(searchText.isEmpty)

                Button("Очистить") {
                    currentSelections.removeAll()
                }
                .disabled(currentSelections.isEmpty)
                .foregroundColor(.red)
            }

                // Строка поиска
            SearchBar(
                placeholder: "Поиск приложений...",
                text: $searchText,
                onClear: { searchText = "" }
            )
        }
        .padding()
    }

    private var footer: some View {
            // Нижняя панель с информацией
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Выбрано: \(currentSelections.count) из \(apps.count)")
                    .foregroundColor(.secondary)

                if !searchText.isEmpty {
                    Text("Найдено: \(filteredApps.count)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            HStack(spacing: 10) {
                Button("Отмена") {
                    isPresented = false
                }

                Button("Готово") {
                    selectedApps = Array(currentSelections)
                    isPresented = false
                }
            }
        }
        .padding()
    }

    private func toggleSelection(_ app: MacApplication) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if currentSelections.contains(app) {
                currentSelections.remove(app)
            } else {
                currentSelections.insert(app)
            }
        }
    }
}
