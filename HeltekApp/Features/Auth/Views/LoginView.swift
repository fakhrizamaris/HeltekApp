//
//  LoginView.swift
//  HeltekApp
//

import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showRegister = false
    
    @StateObject private var authVM = AuthViewModel()
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("userEmail") private var userEmail = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                // Background utama
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // MARK: - Header: Gambar Penuh ke Atas
                        Image("LoginFrame")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 280) // Sedikit ditinggikan agar proporsional saat menabrak ujung atas
                            .clipShape(
                                LoginRoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])
                            )
                            .clipped()
                        
                        // MARK: - Teks Welcome
                        VStack(spacing: 10) {
                            Text("Welcome")
                                .font(ThemeFont.title) // Pastikan ThemeFont.title sudah di-setup
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
                        // TODO: -njknj
                        // FIXME: --
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
                                    
                                    // 💡 PERBAIKAN: Menggunakan 'prompt' bawaan SwiftUI
                                    TextField("", text: $email, prompt: Text("yourname@example.com").foregroundColor(.gray))
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .font(ThemeFont.body)
                                        .foregroundColor(.black)
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
                                Text("Password")
                                    .font(ThemeFont.bodyBold)
                                    .foregroundColor(Color.textPrimary)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "lock")
                                        .foregroundColor(Color.textSecondary)
                                        .frame(width: 20)
                                    
                                    Group {
                                        if isPasswordVisible {
                                            TextField("", text: $password, prompt: Text("••••••••").foregroundColor(.gray))
                                        } else {
                                            SecureField("", text: $password, prompt: Text("••••••••").foregroundColor(.gray))
                                        }
                                    }
                                    .font(ThemeFont.body)
                                    .foregroundColor(.black)
                                    
                                    Spacer()
                                    
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
                            Button(action: {
                                Task {
                                    // Panggil fungsi view model. Error dan loading otomatis ditangani di sana.
                                    await authVM.loginWithEmail(email: email, password: password)
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if authVM.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Login")
                                            .font(ThemeFont.button)
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    (email.isEmpty || password.isEmpty || authVM.isLoading) ? Color.gray.opacity(0.5) : Color.themePrimary
                                )
                                .cornerRadius(12)
                            }
                            .disabled(email.isEmpty || password.isEmpty || authVM.isLoading)
                            .padding(.top, 4)
                            
                            // MARK: - Error Message General
                            if authVM.showError {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                    
                                    Text(authVM.errorMessage)
                                        .font(ThemeFont.caption)
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.1)) // Background merah tipis
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1) // Border merah
                                )
                                .transition(.opacity) // Memberikan efek muncul yang halus
                            }
                            
                            // Link ke Register
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
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .ignoresSafeArea(edges: .top) // 💡 PERBAIKAN: Menghilangkan white space dengan menabrak ujung atas layar
                
                // MARK: - Custom Floating Back Button
                // Menggantikan Toolbar bawaan agar desain lebih menyatu
                Button(action: { hasSeenOnboarding = false }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Circle().fill(Color.white.opacity(0.8)))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding(.top, 16)
                .padding(.leading, 16)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
    
    private func handleLogin() {
    }
    
    // MARK: - Custom Shape untuk memotong sudut tertentu
    struct LoginRoundedCorner: Shape {
        var radius: CGFloat = .infinity
        var corners: UIRectCorner = .allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }
}


