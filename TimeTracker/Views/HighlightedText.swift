//
//  HighlightedText.swift
//  TimeTracker
//
//  Created by Сергей Тришин on 07.01.2026.
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let searchText: String
    let isSelected: Bool

    var body: some View {
        if searchText.isEmpty {
            return Text(text)
                .foregroundColor(isSelected ? .blue : .primary)
        }

        let components = text.components(separatedBy: searchText)

        guard components.count > 1 else {
                // Если нет разделителей, значит нет совпадений
            return Text(text)
                .foregroundColor(isSelected ? .blue : .primary)
        }

        var result = Text("")

        for (index, component) in components.enumerated() {
            if !component.isEmpty {
                result = result + Text(component)
                    .foregroundColor(isSelected ? .blue : .primary)
            }

                // Добавляем подсвеченный текст между компонентами
            if index < components.count - 1 {
                result = result + Text(searchText)
                    .foregroundColor(isSelected ? .blue : .primary)
                    .fontWeight(.bold)
            }
        }

        return result
    }
}
