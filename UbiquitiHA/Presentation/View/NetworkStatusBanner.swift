//
//  NetworkStatusBanner.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 05.10.2025.
//

import SwiftUI

struct NetworkStatusBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Text(message)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
