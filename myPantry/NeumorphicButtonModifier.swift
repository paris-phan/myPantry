//
//  NeumorphicButtonStyle.swift
//  myPantry
//
//  Created by Paris Phan on 3/24/24.
//

import SwiftUI

struct NeumorphicButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("STIX Two Text", size:30))
            .bold()
            .padding()
            .foregroundColor(Color.black.opacity(0.8))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.4)) // Use a near-white color
                    .shadow(color: Color.white.opacity(0.6), radius: 5, x: 5, y: 5)
                    .shadow(color: Color.black.opacity(0.4), radius: 5, x: -5, y: -5)
             )
    }
}

extension View {
    func neumorphicButtonModifier() -> some View {
        self.modifier(NeumorphicButtonModifier())
    }
}
