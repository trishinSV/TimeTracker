//
//  AppDetailsView.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 06.01.2026.
//

import SwiftUI

struct AppDetailsView: View {

    var title: String
    var icon: NSImage?
    var attemptsCount: String
    var usageReport: String?

    @Environment(\.dismiss)
    private var dismiss

    @Binding
    var isPaused: Bool

    var body: some View {
        VStack(spacing: 20) {

            Text(title)
                .font(.title)

            if let icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 64, height: 64)
            }

            VStack(alignment: .leading) {
                Text(attemptsCount)
                    .font(.body)
                    .foregroundColor(.secondary)

                if let usageReport {
                    Text(usageReport)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Text("Статус: \(isPaused ? "Блокировка приостановлена" : "Блокируется")")
                    .font(.body)
                    .foregroundColor(.secondary)

            }

            Toggle("Приостановить блокировку", isOn: $isPaused)
                .toggleStyle(.switch)
                .help("Enable or disable app blocking")

            Button {
                dismiss()
            } label: {
                Text("Закрыть")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .clipShape(Capsule())
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
