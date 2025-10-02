//
//  Modifiers.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

struct SectionLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.gray)
    }
}

struct SectionValueModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14))
    }
}

struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray, radius: 5, x: 0, y: 3)
    }
}

struct PokemonTypeTagModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 8, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(6)
    }
}

struct PokemonCardContainerModifier: ViewModifier {
    let background: Color

    func body(content: Content) -> some View {
        content
            .padding([.leading, .top], 8)
            .background(background)
            .cornerRadius(12)
            .shadow(radius: 2)
    }
}

extension View {
    func typeTag() -> some View {
        modifier(PokemonTypeTagModifier())
    }

    func cardStyle(background: Color) -> some View {
        modifier(PokemonCardContainerModifier(background: background))
    }
    
    func sectionLabel() -> some View {
        modifier(SectionLabelModifier())
    }

    func sectionValue() -> some View {
        modifier(SectionValueModifier())
    }

    func cardBackground() -> some View {
        modifier(CardBackgroundModifier())
    }
}
