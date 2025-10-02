//
//  View+Default.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

extension Image {
    static var hiddenDefault: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .hidden()
    }
}
