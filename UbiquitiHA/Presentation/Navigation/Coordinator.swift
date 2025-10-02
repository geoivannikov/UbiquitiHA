//
//  Coordinator.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()

    func showDetail(pokemon: Pokemon) {
        path.append(AppRoute.detail(pokemon))
    }
}
