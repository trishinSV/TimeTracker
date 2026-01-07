//
//  ContentView.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 06.01.2026.
//

import SwiftUI

struct ContentView: View {

    @StateObject
    var viewModel: ContentViewModel = ContentViewModel()

    @State private var isShowingSelection = false
    @State private var selectedApp: MacApplication?

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                    // Поиск по выбранным элементам
                if !viewModel.blockedApps.isEmpty {
                    BlockedAppsTableView(
                        blockedApps: $viewModel.blockedApps,
                        isBlockingEnabled: $viewModel.isBlockingEnabled,
                        pausedApps: viewModel.pausedApps,
                        onAppSelected: { appName in
                            selectedApp = appName
                        }
                    )
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)

                        Text("Приложения не выбраны")
                            .foregroundColor(.secondary)

                        Text("Нажмите кнопку ниже, чтобы добавить приложения")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }

                Spacer()

                HStack {
                    Button {
                        isShowingSelection = true
                    } label: {
                        Text("Выбрать приложения")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .clipShape(Capsule())
                    .controlSize(.large)

                    Text("Всего выбрано: \(viewModel.blockedApps.count)")
                        .foregroundColor(.secondary)

                    Spacer()

                    if !viewModel.blockedApps.isEmpty {
                        Text(viewModel.blockedApps.map(\.name).joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .padding()
            .frame(minWidth: 450, minHeight: 400)
            .sheet(isPresented: $isShowingSelection) {
                AppSelectionView(
                    apps: viewModel.currentApps,
                    selectedApps: $viewModel.blockedApps,
                    isPresented: $isShowingSelection
                )
            }
            .sheet(item: $selectedApp) { item in
                AppDetailsView(
                    title: item.name,
                    icon: item.icon,
                    attemptsCount: "Количество попыток открыть: \(viewModel.attemptCounts[item.bundleIdentifier] ?? 0)",
                    usageReport: viewModel.usageReport(for: item.bundleIdentifier),
                    isPaused: Binding(
                        get: { viewModel.isPaused(for: item.bundleIdentifier) },
                        set: { newValue in
                            let currentValue = viewModel.isPaused(for: item.bundleIdentifier)
                            if newValue != currentValue {
                                viewModel.togglePause(for: item.bundleIdentifier)
                            }
                        }
                    )
                )
                .background(.ultraThickMaterial)
            }
        }
        .padding()
        .onAppear {
            viewModel.startTracking()
        }
        .background {
            Image("stars")
                .resizable()
        }
        .preferredColorScheme(.dark)
    }
}
