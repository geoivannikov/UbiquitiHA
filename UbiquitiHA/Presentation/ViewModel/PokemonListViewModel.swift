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

    @Inject private var loadUseCase: LoadPokemonsUseCaseProtocol
    @Inject private var networkMonitor: NetworkMonitorProtocol

    // MARK: - Paging

    private(set) var offset = 0
    private let pageSize = 30

    // MARK: - Init

    init() {
        self.isConnected = networkMonitor.isConnected
        
        networkMonitor.onConnectionChange { [weak self] isConnected in
            guard let self = self else {
                return
            }
            Task { @MainActor in
                let wasConnected = self.isConnected
                self.isConnected = isConnected
                if wasConnected != isConnected {
                    self.showNetworkStatusBanner()
                }
            }
            
            if isConnected, self.pokemons.isEmpty {
                Task { await self.loadNextPage() }
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
        if offset == 0, !networkMonitor.isConnected {
            await MainActor.run { errorMessage = PokemonError.noConnection.errorDescription }
        }
        
        guard await MainActor.run(body: { !isLoading }) else { return }

        await MainActor.run { isLoading = true }

        defer {
            Task {
                await MainActor.run { isLoading = false }
            }
        }

        do {
            let newPokemons = try await loadUseCase.execute(offset: offset, limit: pageSize)
            let existingIds = Set(pokemons.map { $0.id })
            let uniqueNewPokemons = newPokemons.filter { !existingIds.contains($0.id) }

            await MainActor.run {
                pokemons.append(contentsOf: uniqueNewPokemons)
                offset += pageSize
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}
