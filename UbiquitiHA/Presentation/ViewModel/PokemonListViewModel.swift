//
//  PokemonListViewModel.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import Foundation

protocol PokemonListViewModelProtocol: ObservableObject {
    var pokemons: [Pokemon] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get set }
    var isConnected: Bool { get }
    var showNetworkStatus: Bool { get }
    var networkStatusMessage: String { get }
    func loadNextPage() async
}

final class PokemonListViewModel: PokemonListViewModelProtocol {
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

    private(set) var offset = Constants.initialOffset
    private let pageSize = Constants.defaultPageSize
    private var networkCallbackId: UUID?

    // MARK: - Init

    init() {
        self.isConnected = networkMonitor.isConnected
        
        networkCallbackId = networkMonitor.onConnectionChange { [weak self] isConnected in
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
    
    deinit {
        if let callbackId = networkCallbackId {
            networkMonitor.removeCallback(callbackId)
        }
    }

    // MARK: - Private Methods
    @MainActor
    private func showNetworkStatusBanner() {
        networkStatusMessage = isConnected ? "🌐 Connected" : "📶 No Internet"
        showNetworkStatus = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.networkBannerDisplayDuration) { [weak self] in
            self?.showNetworkStatus = false
        }
    }

    // MARK: - Public Methods

    func loadNextPage() async {
        if offset == Constants.initialOffset, !networkMonitor.isConnected {
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
