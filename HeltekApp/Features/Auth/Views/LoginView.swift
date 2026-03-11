//
//  LoginView.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 11/03/26.
//

import SwiftUI
import AuthenticationServices // Framework bawaan Apple untuk "Sign in with Apple"

struct LoginView: View {
    
    // State untuk isi form — seperti useState di React
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showRegister = false
    
    // AppStorage untuk simpan status login
    // Saat ini = true, HeltekAppApp.swift akan auto-redirect ke MainTabView
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // MARK: - Gambar Header
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(hex: "FFF0E8"))
                        .frame(height: 220)
                    
                    Image(systemName: "LoginFrame")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.themePrimary)
                        .frame(height: 120)
                }
                
                // MARK: - Form Login
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Judul
                    VStack(alignment: .center, spacing: 8) {
                        Text("Welcome")
                            .font(ThemeFont.title)
                            .foregroundColor(Color.textPrimary)
                        
                        Text("Ready to break the sedentary cycle? Let's move.")
                            .font(ThemeFont.body)
                            .foregroundColor(Color.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Field Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(ThemeFont.caption)
                            .foregroundColor(Color.textSecondary)
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(Color.textSecondary)
                            
                            // TextField = <input type="text"> versi SwiftUI
                            TextField("yourname@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .font(ThemeFont.body)
                        }
                        .padding(14)
                        .background(Color.themeBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Field Password
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Password")
                                .font(ThemeFont.caption)
                                .foregroundColor(Color.textSecondary)
                            
                            Spacer()
                            
                            // Forgot Password link
                            Button("Forgot Password?") {
                                // TODO: Implementasi reset password
                            }
                            .font(ThemeFont.caption)
                            .foregroundColor(Color.themePrimary)
                        }
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(Color.textSecondary)
                            
                            // Kondisional: tampilkan teks biasa atau tersembunyi
                            if isPasswordVisible {
                                TextField("••••••••", text: $password)
                                    .font(ThemeFont.body)
                            } else {
                                // SecureField = <input type="password">
                                SecureField("••••••••", text: $password)
                                    .font(ThemeFont.body)
                            }
                            
                            // Toggle tampilkan/sembunyikan password
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(Color.textSecondary)
                            }
                        }
                        .padding(14)
                        .background(Color.themeBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Tombol Login Utama
                    Button(action: {
                        handleLogin()
                    }) {
                        HStack {
                            Text("Login")
                                .font(ThemeFont.button)
                            Image(systemName: "arrow.right.square")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.themePrimary)
                        .cornerRadius(ThemeStyle.cornerRadius)
                    }
                    
                    // Divider "Or continue with"
                    HStack {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        Text("Or continue with")
                            .font(ThemeFont.caption)
                            .foregroundColor(Color.textSecondary)
                            .fixedSize()
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                    }
                    
                    // MARK: - Tombol Social Login
                    VStack(spacing: 12) {
                        
                        // Sign in with Apple (framework resmi dari Apple)
                        SignInWithAppleButton(.signIn) { request in
                            // Kita minta data nama dan email dari Apple
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result: result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(ThemeStyle.cornerRadius)
                        
                    }
                    
                    // Link Sign Up
                    HStack {
                        Spacer()
                        Text("Don't have an account?")
                            .font(ThemeFont.caption)
                            .foregroundColor(Color.textSecondary)
                        
                        Button("Sign Up") {
                            showRegister = true
                        }
                        .font(ThemeFont.caption)
                        .foregroundColor(Color.themePrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        // Tombol back untuk ke onboarding (opsional, untuk testing)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Kembali ke onboarding (reset AppStorage)
                    hasSeenOnboarding = false
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(Color.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
    
    // MARK: - Fungsi Login Biasa (Email/Password)
    // Untuk MVP: kita skip validasi server, langsung set isLoggedIn = true
    // Ini seperti localStorage.setItem('isLoggedIn', true)
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        // TODO: Ganti dengan validasi CloudKit nanti di Fitur 2
        // Untuk sekarang, langsung masuk aja
        isLoggedIn = true
    }
    
    // MARK: - Fungsi Sign In with Apple
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            // Kalau berhasil, ambil credential dari Apple
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                
                // Simpan userIdentifier — ini ID unik dari Apple, seperti user ID di database
                let userID = credential.user
                UserDefaults.standard.set(userID, forKey: "appleUserID")
                
                print("✅ Sign in with Apple berhasil! User ID: \(userID)")
                
                // Tandai sudah login → app otomatis pindah ke MainTabView
                isLoggedIn = true
            }
            
        case .failure(let error):
            // Gagal login — tampilkan error
            print("❌ Sign in with Apple gagal: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        LoginView()
    }
}
