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
                AsyncImage(url: URL(string: pokemon.imgURL)) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFit()
                    } else {
                            Image.hiddenDefault
                    }
                }
            }
        }
        .cardStyle(background: pokemon.backgroundColor)
    }
}
