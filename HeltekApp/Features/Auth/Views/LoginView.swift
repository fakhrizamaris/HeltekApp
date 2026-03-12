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
    
    // ViewModel yang mengurus semua logika login
    @StateObject private var viewModel = AuthViewModel()
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // MARK: - Header: Gambar + Custom Navbar menimpa gambar
                        ZStack(alignment: .top) {
                            
                            // Gambar LoginFrame dari Assets
                            Image("LoginFrame")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 260)
                                .clipShape(
                                    RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])
                                )
                                .clipped()
                            
                            // Custom Navbar — menimpa gambar di atas
                            HStack {
                                
                                // Tombol back — lingkaran putih dengan shadow
                                Button(action: {
                                    // Kembali ke onboarding
                                    hasSeenOnboarding = false
                                }) {
                                    ZStack {
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
                                
                                Spacer()
                                
                                // Judul "Login" di tengah
                                Text("Login")
                                    .font(ThemeFont.bodyBold)
                                    .foregroundColor(Color.textPrimary)
                                
                                Spacer()
                                
                                // Spacer kanan — lebar sama dengan tombol back
                                // supaya "Login" benar-benar di tengah
                                Color.clear.frame(width: 36, height: 36)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 56) // Jaga jarak dari status bar iPhone
                        }
                        
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
                        .padding(.top, 28)
                        .padding(.bottom, 24)
                        
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
                                    
                                    // ZStack untuk custom placeholder warna hitam
                                    ZStack(alignment: .leading) {
                                        if email.isEmpty {
                                            Text("yourname@example.com")
                                                .font(ThemeFont.body)
                                                .foregroundColor(.black.opacity(0.35))
                                        }
                                        TextField("", text: $email)
                                            .keyboardType(.emailAddress)
                                            .autocapitalization(.none)
                                            .font(ThemeFont.body)
                                            .foregroundColor(.black)
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
                            
                            // Field Password
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Password")
                                        .font(ThemeFont.bodyBold)
                                        .foregroundColor(Color.textPrimary)
                                    
                                    Spacer()
                                    
                                    Button("Forgot Password?") {
                                        // TODO: Implementasi reset password
                                    }
                                    .font(ThemeFont.caption)
                                    .foregroundColor(Color.themePrimary)
                                }
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "lock")
                                        .foregroundColor(Color.textSecondary)
                                        .frame(width: 20)
                                    
                                    ZStack(alignment: .leading) {
                                        if password.isEmpty {
                                            Text("••••••••")
                                                .font(ThemeFont.body)
                                                .foregroundColor(.black.opacity(0.35))
                                        }
                                        if isPasswordVisible {
                                            TextField("", text: $password)
                                                .font(ThemeFont.body)
                                                .foregroundColor(.black)
                                        } else {
                                            SecureField("", text: $password)
                                                .font(ThemeFont.body)
                                                .foregroundColor(.black)
                                        }
                                    }
                                    
                                    // Toggle show/hide password
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
                            
                            // Tombol Login Email/Password
                            Button(action: { handleLogin() }) {
                                HStack(spacing: 8) {
                                    Text("Login")
                                        .font(ThemeFont.button)
                                        .foregroundColor(.white)
                                    Image(systemName: "arrow.right.square.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.themePrimary)
                                .cornerRadius(ThemeStyle.cornerRadius)
                            }
                            .padding(.top, 4)
                            
                            // Divider "Or continue with"
                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                Text("Or continue with")
                                    .font(ThemeFont.caption)
                                    .foregroundColor(Color.textSecondary)
                                    .fixedSize()
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            
                            // MARK: - Tombol Sign in with Apple
                            // Kalau sedang loading → tampilkan spinner
                            // Kalau tidak → tampilkan tombol Apple
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView().tint(Color.themePrimary)
                                    Text("Signing in...")
                                        .font(ThemeFont.body)
                                        .foregroundColor(Color.textSecondary)
                                        .padding(.leading, 8)
                                    Spacer()
                                }
                                .frame(height: 54)
                                
                            } else {
                                SignInWithAppleButton(.signIn) { request in
                                    // Persiapkan nonce SEBELUM sheet Apple muncul
                                    viewModel.prepareAppleSignIn(request: request)
                                } onCompletion: { result in
                                    // Handle hasil login
                                    viewModel.handleAppleSignIn(result: result)
                                }
                                .signInWithAppleButtonStyle(.white)
                                .frame(height: 54)
                                .cornerRadius(ThemeStyle.cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                                )
                            }
                            
                            // MARK: - Link ke Register
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
                            .padding(.bottom, 40)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .navigationBarHidden(true)
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
            // Alert muncul kalau Apple Sign In gagal
            .alert("Login Gagal", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            print("⚠️ Email atau password kosong!")
            return
        }
        print("✅ Login email ditekan — masuk ke MainTabView")
        isLoggedIn = true
    }
}

#Preview {
    LoginView()
        .onAppear {
            // Reset AppStorage supaya preview mulai dari kondisi bersih
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
        }
}
