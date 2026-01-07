//
//  AppRowView.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 07.01.2026.
//

import SwiftUI

struct AppRowView: View {
    let app: MacApplication
    let isPaused: Bool
    let onDelete: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack {
                // Иконка состояния
            Image(systemName: isPaused ? "pause.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(isPaused ? .orange : .green)

            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
            }

                // Описание приложения
            Text(app.name)
                .lineLimit(1)

                // Бейдж "Paused"
            if isPaused {
                BadgeView(text: "Paused", color: .orange)
            }

            Spacer()

                // Кнопка удаления
            DeleteButton(onDelete: onDelete, appName: app.name)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isPaused ? Color.orange.opacity(0.3) : Color.green.opacity(0.3))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isPaused ? Color.orange.opacity(0.5) : Color.green.opacity(0.5), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}

    // Компонент бейджа
struct BadgeView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .cornerRadius(4)
    }
}

    // Компонент кнопки удаления
struct DeleteButton: View {
    let onDelete: () -> Void
    let appName: String

    var body: some View {
        Button(action: onDelete) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 16))
        }
        .buttonStyle(.borderless)
        .help("Удалить \(appName)")
    }
}
