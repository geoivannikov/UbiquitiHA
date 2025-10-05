//
//  PokemonDetailView.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

struct PokemonDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: PokemonDetailViewModel

    init(viewModel: PokemonDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .top) {
            viewModel.backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(viewModel.backgroundColor)
                } else if viewModel.details.isEmpty {
                    EmptyView()
                        .background(viewModel.backgroundColor)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
                            DescriptionSection(description: viewModel.details.description)
                            HeightWeightSection(height: viewModel.details.height, weight: viewModel.details.weight)
                            InfoSection(baseExperience: viewModel.details.baseExperience,
                                        species: viewModel.details.species,
                                        formsCount: viewModel.details.formsCount)
                            TypeSection(types: viewModel.details.types,
                                        color: viewModel.backgroundColor)
                            Spacer(minLength: 40)
                        }
                        .padding(20)
                    }
                }
            }
            .background(
                Color(.systemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .ignoresSafeArea(.container, edges: [.horizontal, .bottom])
            )
            .padding(.top, 20)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(viewModel.details.name.capitalized)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .onLoad {
                await viewModel.load()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
    }
}

private struct DescriptionSection: View {
    let description: String

    var body: some View {
        Text(description)
            .sectionValue()
            .padding(.top)
    }
}

private struct HeightWeightSection: View {
    let height: Int
    let weight: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Height").sectionLabel()
                Text("\(height) cm").sectionValue()
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Weight").sectionLabel()
                Text("\(weight) kg").sectionValue()
            }
        }
        .cardBackground()
    }
}

private struct InfoSection: View {
    let baseExperience: Int
    let species: String
    let formsCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Info")
                .font(.headline)
                .foregroundColor(.primary)
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Base exp:").sectionLabel()
                    Text("Species:").sectionLabel()
                    Text("Forms count:").sectionLabel()
                }
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(baseExperience) exp").sectionValue()
                    Text(species).sectionValue()
                    Text("\(formsCount)").sectionValue()
                }
            }
        }
    }
}

private struct TypeSection: View {
    let types: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Type")
                .font(.headline)
                .foregroundColor(.primary)
            HStack {
                ForEach(types, id: \.self) { type in
                    Text(type.capitalized)
                        .foregroundColor(.white)
                        .font(.caption.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(color)
                        .cornerRadius(8)
                }
            }
        }
    }
}
