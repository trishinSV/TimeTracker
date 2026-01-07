//
//  SelectionRow.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 07.01.2026.
//  Note: File was originally named SelectionRaw.swift (typo), struct name is correct
//

import SwiftUI

struct SelectionRow: View {
    let string: String
    let isSelected: Bool
    let searchText: String
    let icon: NSImage?
    let onToggle: () -> Void

    var body: some View {
        HStack {
            if let icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
            }

            // Текст с подсветкой поиска
            if searchText.isEmpty || !string.localizedCaseInsensitiveContains(searchText) {
                Text(string)
                    .foregroundColor(isSelected ? .blue : .primary)
            } else {
                HighlightedText(
                    text: string,
                    searchText: searchText,
                    isSelected: isSelected
                )
            }

            Spacer()

            // Индикатор выбора
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
        .contextMenu {
            if isSelected {
                Button {
                    onToggle()
                } label: {
                    Label("Убрать из выбранных", systemImage: "minus.circle")
                }
            }

            Button {
                // Копирование в буфер обмена
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(string, forType: .string)
            } label: {
                Label("Скопировать", systemImage: "doc.on.doc")
            }
        }
        .padding(.vertical, 4)
    }
}
