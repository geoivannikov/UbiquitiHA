//
//  View+errorAlert.swift
//  UbiquitiHA
//
//  Created by Ivannikov Georgiy on 02.10.2025.
//

import SwiftUI

extension View {
    func errorAlert(
        isPresented: Binding<Bool>,
        title: String = "Error",
        message: String?,
        dismissButton: String = "OK"
    ) -> some View {
        self.alert(title, isPresented: isPresented, actions: {
            Button(dismissButton, role: .cancel) {
                isPresented.wrappedValue = false
            }
        }, message: {
            if let message = message {
                Text(message)
            }
        })
    }
    
    func errorAlert(
        errorMessage: Binding<String?>,
        title: String = "Error",
        dismissButton: String = "OK"
    ) -> some View {
        self.errorAlert(
            isPresented: .constant(errorMessage.wrappedValue != nil),
            title: title,
            message: errorMessage.wrappedValue,
            dismissButton: dismissButton
        )
        .onChange(of: errorMessage.wrappedValue) { _, newValue in
            if newValue == nil {
                errorMessage.wrappedValue = nil
            }
        }
    }
}
