//
//  HomeView.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Ini Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
                
            Button(action: {
                authVM.logout()
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    HomeView()
}
