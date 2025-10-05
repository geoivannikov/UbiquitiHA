//
//  PokemonCardView.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

struct PokemonCardView: View {
    let pokemon: Pokemon

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(pokemon.name)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(pokemon.types, id: \.self) { type in
                    Text(type).typeTag()
                }
                Spacer()
            }
            .padding(.top, 16)
            Spacer()
            VStack(alignment: .trailing) {
                Text(pokemon.number)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.trailing, 8)
                Spacer()
                if let imageData = pokemon.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .hidden()
                }
            }
        }
        .cardStyle(background: pokemon.backgroundColor)
    }
}

// MARK: - Preview
#Preview("Electric Type") {
    let mockPokemon = Pokemon(
        id: 1,
        name: "Pikachu",
        number: "#001",
        types: ["Electric"],
        imageData: nil,
        height: 40,
        weight: 6,
        baseExperience: 112
    )
    
    return PokemonCardView(pokemon: mockPokemon)
        .frame(width: 180, height: 120)
        .padding()
}

#Preview("Fire Type With Long Name") {
    let mockPokemon = Pokemon(
        id: 4,
        name: "Charmander Long name",
        number: "#004",
        types: ["Fire"],
        imageData: nil,
        height: 60,
        weight: 8,
        baseExperience: 62
    )
    
    return PokemonCardView(pokemon: mockPokemon)
        .frame(width: 180, height: 120)
        .padding()
}
