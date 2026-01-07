//
//  SearchBar.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 07.01.2026.
//

import SwiftUI

struct SearchBar: View {

    let placeholder: String

    @Binding
    var text: String

    var onClear: () -> Void
    var showClearButton: Bool = true

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 14))

            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)

            if showClearButton && !text.isEmpty {
                Button {
                    text = ""
                    onClear()
                    isFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.borderless)
                .transition(.opacity)
            }
        }
    }
}
