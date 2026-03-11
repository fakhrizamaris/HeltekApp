//
//  LoginView.swift
//  HeltekApp
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showRegister = false
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    
                    // MARK: - Gambar Header (rounded card peach)
                    Image("LoginFrame")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    // MARK: - Teks Welcome
                    VStack(spacing: 10) {
                        Text("Welcome")
                            .font(ThemeFont.title)
                            .foregroundColor(Color.textPrimary)
                        
                        Text("Ready to break the sedentary cycle? Let's move.")
                            .font(ThemeFont.body)
                            .foregroundColor(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 28)
                    
                    // MARK: - Form
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Field Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(ThemeFont.bodyBold)
                                .foregroundColor(Color.textPrimary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .foregroundColor(Color.textSecondary)
                                    .frame(width: 20)
                                
                                TextField("yourname@example.com", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .font(ThemeFont.body)
                                    .foregroundColor(Color.textPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Field Password
                        VStack(alignment: .leading, spacing: 8) {
                            // Label + Forgot Password dalam satu baris
                            HStack {
                                Text("Password")
                                    .font(ThemeFont.bodyBold)
                                    .foregroundColor(Color.textPrimary)
                                
                                Spacer()
                                
                                Button("Forgot Password?") {
                                    // TODO: Reset password
                                }
                                .font(ThemeFont.caption)
                                .foregroundColor(Color.themePrimary)
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .foregroundColor(Color.textSecondary)
                                    .frame(width: 20)
                                
                                if isPasswordVisible {
                                    TextField("••••••••", text: $password)
                                        .font(ThemeFont.body)
                                } else {
                                    SecureField("••••••••", text: $password)
                                        .font(ThemeFont.body)
                                }
                                
                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(Color.textSecondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // MARK: - Tombol Login
                        Button(action: { handleLogin() }) {
                            HStack(spacing: 8) {
                                Text("Login")
                                    .font(ThemeFont.button)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.themePrimary)
                            .cornerRadius(ThemeStyle.cornerRadius)
                        }
                        .padding(.top, 4)
                        
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("Or continue with")
                                .font(ThemeFont.caption)
                                .foregroundColor(Color.textSecondary)
                                .fixedSize() // supaya teks tidak wrap
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        
                        // MARK: - Tombol Continue with Apple
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result: result)
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 54)
                        .cornerRadius(ThemeStyle.cornerRadius)
                        .overlay(
                            // Border abu-abu tipis di luar tombol Apple
                            RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        )
                        
                        // MARK: - Link Sign Up
                        HStack(spacing: 4) {
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
                        .padding(.top, 4)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Tombol back kiri atas
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Kembali ke onboarding
                        hasSeenOnboarding = false
                    }) {
                        ZStack {
                            // Lingkaran background abu-abu seperti di desain
                            Circle()
                                .fill(Color.white)
                                .frame(width: 36, height: 36)
                                .shadow(
                                    color: Color.black.opacity(0.08),
                                    radius: 4, x: 0, y: 2
                                )
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.textPrimary)
                        }
                    }
                }
                
                // Judul "Login" di tengah
                ToolbarItem(placement: .principal) {
                    Text("Login")
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(Color.textPrimary)
                }
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
    
    // MARK: - Fungsi Login
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        print("✅ Login ditekan — set isLoggedIn = true")
        // TODO: Validasi ke CloudKit di Fitur 2
        isLoggedIn = true
    }
    
    // MARK: - Fungsi Apple Sign In
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userID = credential.user
                UserDefaults.standard.set(userID, forKey: "appleUserID")
                print("✅ Apple Sign In berhasil! ID: \(userID)")
                isLoggedIn = true
            }
        case .failure(let error):
            print("❌ Apple Sign In gagal: \(error.localizedDescription)")
        }
    }
}

#Preview {
    LoginView()
}
