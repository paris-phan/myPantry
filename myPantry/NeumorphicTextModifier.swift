//
//  NeumorphicTextModifier.swift
//  myPantry
//
//  Created by Paris Phan on 3/24/24.
//

import SwiftUI
struct NeumorphicTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body) // Adjust font as needed
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .shadow(color: Color.white.opacity(0.7), radius: 3, x: 3, y: 3)
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: -3, y: -3)
            )
    }
}
extension View {
    func neumorphicTextModifier() -> some View {
        self.modifier(NeumorphicTextModifier())
    }
}
