//
//  PokemonListViewModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

final class PokemonListViewModel: ObservableObject {
    // MARK: - Public State

    @Published private(set) var pokemons: [Pokemon] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var isConnected = false
    @Published var showNetworkStatus = false
    @Published var networkStatusMessage = ""

    // MARK: - Dependencies

    private let loadUseCase: LoadPokemonsUseCaseProtocol
    private let networkMonitor: NetworkMonitorProtocol

    // MARK: - Paging

    private(set) var offset = 0
    private let pageSize = 50

    // MARK: - Init

    init(loadUseCase: LoadPokemonsUseCaseProtocol = DIContainer.shared.resolve(),
         networkMonitor: NetworkMonitorProtocol = DIContainer.shared.resolve()) {
        self.loadUseCase = loadUseCase
        self.networkMonitor = networkMonitor
        self.isConnected = networkMonitor.isConnected
        
        networkMonitor.onConnectionChange { [weak self] isConnected in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? false
                self?.isConnected = isConnected
                if wasConnected != isConnected {
                    self?.showNetworkStatusBanner()
                }
            }
        }
    }

    // MARK: - Private Methods
    @MainActor
    private func showNetworkStatusBanner() {
        networkStatusMessage = isConnected ? "🌐 Connected" : "📶 No Internet"
        showNetworkStatus = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showNetworkStatus = false
        }
    }

    // MARK: - Public Methods

    func loadNextPage() async {
        guard await MainActor.run(body: { !isLoading }) else { return }

        await MainActor.run { isLoading = true }

        defer {
            Task {
                await MainActor.run { isLoading = false }
            }
        }

        do {
            let newPokemons = try await loadUseCase.execute(offset: offset, limit: pageSize)

            await MainActor.run {
                pokemons.append(contentsOf: newPokemons)
                offset += pageSize
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}
