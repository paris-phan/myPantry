//
//  NeumorphicTextFieldModifier.swift
//  myPantry
//
//  Created by Paris Phan on 3/24/24.
//
import SwiftUI

struct NeumorphicTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(Color.black.opacity(0.8))
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.4))
                    .shadow(color: Color.white.opacity(0.7), radius: 4, x: 5, y: 5)
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: -5, y: -5)
            )
            .padding()
    }
}

extension View {
    func neumorphicTextFieldStyle() -> some View {
        self.modifier(NeumorphicTextFieldModifier())
    }
}
