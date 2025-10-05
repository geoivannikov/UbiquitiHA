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
                    .lineLimit(1)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)

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
