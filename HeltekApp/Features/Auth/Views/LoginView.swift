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
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("userEmail") private var userEmail = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    
                    // MARK: - Header: Gambar (Tanpa Custom Navbar)
                    Image("LoginFrame")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 240)
                        .clipShape(
                            RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])
                        )
                        .clipped()
                    
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
                                    print("Forgot password ditekan")
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
                        
                        // Tombol Login
                        Button(action: { handleLogin() }) {
                            HStack(spacing: 8) {
                                Text("Login")
                                    .font(ThemeFont.button)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                (email.isEmpty || password.isEmpty) ? Color.gray.opacity(0.5) : Color.themePrimary
                            )
                            .cornerRadius(ThemeStyle.cornerRadius)
                        }
                        .disabled(email.isEmpty || password.isEmpty)
                        .padding(.top, 4)
                        
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
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            // Background diaplikasikan di ScrollView, bukan ZStack
            .background(Color.themeBackground.ignoresSafeArea())
            // 💡 PERBAIKAN: Menggunakan Toolbar resmi SwiftUI (Konsisten dengan Register)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { hasSeenOnboarding = false }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.textPrimary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Login")
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(Color.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
    
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else { return }
        userEmail = email
        print("✅ Login simulasi berhasil! Masuk sebagai: \(email)")
        isLoggedIn = true
    }
}

#Preview {
    LoginView()
}
