//
//  UserProfileSetupView.swift
//  HeltekApp
//
//  View untuk mengisi nama user setelah registrasi.
//  Desain single-page yang clean dan welcoming.
//

import SwiftUI

struct UserProfileSetupView: View {
    
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.themeBackground,
                    Color.themePrimary.opacity(0.05),
                    Color.themeBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: - Header
                headerSection
                
                Spacer()
                    .frame(height: 40)
                
                // MARK: - Name Input
                nameInputSection
                    .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 32)
                
                // MARK: - Continue Button
                continueButton
                    .padding(.horizontal, 24)
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateContent = true
            }
        }
        .alert("Oops!", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.themePrimaryFaded)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.themePrimary)
            }
            .opacity(animateContent ? 1 : 0)
            .scaleEffect(animateContent ? 1 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateContent)
            
            Text("Siapa Nama Kamu?")
                .font(ThemeFont.title)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Biar kita bisa menyapamu dengan hangat 👋")
                .font(ThemeFont.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // MARK: - Name Input Section
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nama Lengkap")
                .font(ThemeFont.bodyBold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .foregroundColor(.themePrimary)
                    .frame(width: 20)
                
                TextField("Masukkan nama lengkapmu", text: $viewModel.fullName)
                    .font(ThemeFont.body)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
            }
            .padding(16)
            .background(Color.themeSurface)
            .cornerRadius(ThemeStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                    .stroke(
                        viewModel.fullName.isEmpty
                            ? Color.clear
                            : Color.themePrimary.opacity(0.3),
                        lineWidth: 1.5
                    )
            )
            
            // Hint text
            Text("Nama ini akan ditampilkan di profil dan leaderboard")
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
                .padding(.leading, 4)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 15)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateContent)
    }
    
    // MARK: - Continue Button
    private var continueButton: some View {
        Button {
            Task {
                await viewModel.saveProfile()
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Lanjutkan")
                        .font(ThemeFont.button)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                    .fill(
                        viewModel.isNameValid
                            ? Color.themePrimary
                            : Color.themePrimary.opacity(0.4)
                    )
            )
            .shadow(
                color: viewModel.isNameValid
                    ? Color.themePrimary.opacity(0.3)
                    : Color.clear,
                radius: 8, x: 0, y: 4
            )
        }
        .disabled(!viewModel.isNameValid || viewModel.isLoading)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 15)
        .animation(.easeOut(duration: 0.6).delay(0.3), value: animateContent)
    }
}

// MARK: - Preview
#Preview {
    UserProfileSetupView()
}
