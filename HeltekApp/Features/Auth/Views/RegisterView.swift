//
//  RegisterView.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 11/03/26.
//


import SwiftUI
import AuthenticationServices

struct RegisterView: View {
    
    // State untuk setiap field form
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    // State untuk error message
    @State private var errorMessage = ""
    @State private var showError = false
    
    // Untuk kembali ke LoginView (dismiss sheet)
    @Environment(\.dismiss) private var dismiss
    
    // Saat ini = true, app otomatis pindah ke MainTabView
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    
                    // MARK: - Header gambar (sama dengan LoginView)
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: "FFF0E8"))
                            .frame(height: 180)
                        
                        Image(systemName: "person.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.themePrimary)
                            .frame(height: 80)
                    }
                    
                    // MARK: - Form Register
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Judul halaman
                        VStack(alignment: .center, spacing: 8) {
                            Text("Create Account")
                                .font(ThemeFont.title)
                                .foregroundColor(Color.textPrimary)
                            
                            Text("Start your journey to a healthier life.")
                                .font(ThemeFont.body)
                                .foregroundColor(Color.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // MARK: - Field: Full Name
                        FormField(
                            label: "Full Name",
                            icon: "person",
                            placeholder: "Your full name",
                            text: $fullName
                        )
                        
                        // MARK: - Field: Email
                        FormField(
                            label: "Email",
                            icon: "envelope",
                            placeholder: "yourname@example.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        // MARK: - Field: Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(ThemeFont.caption)
                                .foregroundColor(Color.textSecondary)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(Color.textSecondary)
                                
                                if isPasswordVisible {
                                    TextField("Min. 8 karakter", text: $password)
                                        .font(ThemeFont.body)
                                } else {
                                    SecureField("Min. 8 karakter", text: $password)
                                        .font(ThemeFont.body)
                                }
                                
                                Button(action: { isPasswordVisible.toggle() }) {
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
                        
                        // MARK: - Field: Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(ThemeFont.caption)
                                .foregroundColor(Color.textSecondary)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color.textSecondary)
                                
                                if isConfirmPasswordVisible {
                                    TextField("Ulangi password", text: $confirmPassword)
                                        .font(ThemeFont.body)
                                } else {
                                    SecureField("Ulangi password", text: $confirmPassword)
                                        .font(ThemeFont.body)
                                }
                                
                                Button(action: { isConfirmPasswordVisible.toggle() }) {
                                    Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(Color.textSecondary)
                                }
                            }
                            .padding(14)
                            // Highlight merah kalau password tidak cocok
                            .background(Color.themeBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        passwordMismatch ? Color.alertDestructive : Color.gray.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                            
                            // Pesan error password tidak cocok
                            if passwordMismatch {
                                Text("Password tidak cocok")
                                    .font(ThemeFont.caption)
                                    .foregroundColor(Color.alertDestructive)
                            }
                        }
                        
                        // MARK: - Error Message General
                        if showError {
                            Text(errorMessage)
                                .font(ThemeFont.caption)
                                .foregroundColor(Color.alertDestructive)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(Color.alertBackground)
                                .cornerRadius(8)
                        }
                        
                        // MARK: - Tombol Register
                        Button(action: { handleRegister() }) {
                            Text("Create Account")
                                .font(ThemeFont.button)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    // Tombol abu-abu kalau form belum lengkap
                                    formIsValid ? Color.themePrimary : Color.gray.opacity(0.4)
                                )
                                .cornerRadius(ThemeStyle.cornerRadius)
                        }
                        .disabled(!formIsValid) // Nonaktifkan tombol kalau form belum valid
                        
                        // Divider
                        HStack {
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                            Text("Or sign up with")
                                .font(ThemeFont.caption)
                                .foregroundColor(Color.textSecondary)
                                .fixedSize()
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        }
                        
                        // Sign in with Apple (bisa juga untuk register)
                        SignInWithAppleButton(.signUp) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result: result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(ThemeStyle.cornerRadius)
                        
                        // Link kembali ke Login
                        HStack {
                            Spacer()
                            Text("Already have an account?")
                                .font(ThemeFont.caption)
                                .foregroundColor(Color.textSecondary)
                            
                            Button("Log In") {
                                // Tutup sheet RegisterView, kembali ke LoginView
                                dismiss()
                            }
                            .font(ThemeFont.caption)
                            .foregroundColor(Color.themePrimary)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 44)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color.textPrimary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Register")
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(Color.textPrimary)
                }
            }
        }
    }
    
    // MARK: - Validasi: password tidak cocok?
    // Hanya dicek kalau confirmPassword sudah diisi
    private var passwordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }
    
    // MARK: - Validasi: semua field sudah diisi dan valid?
    private var formIsValid: Bool {
        !fullName.isEmpty &&
        !email.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }
    
    // MARK: - Fungsi Register
    private func handleRegister() {
        guard formIsValid else { return }
        
        // Simpan nama user ke UserDefaults supaya bisa ditampilkan di HomeView
        // Ini seperti: localStorage.setItem('userName', fullName)
        UserDefaults.standard.set(fullName, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        // TODO: Di Fitur 2, kirim data ini ke CloudKit
        // Untuk sekarang, langsung tandai sudah login
        isLoggedIn = true
    }
    
    // MARK: - Fungsi Apple Sign In
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Simpan data dari Apple ke UserDefaults
                let userID = credential.user
                let name = credential.fullName?.givenName ?? "User"
                
                UserDefaults.standard.set(userID, forKey: "appleUserID")
                UserDefaults.standard.set(name, forKey: "userName")
                
                print("✅ Apple Sign Up berhasil! Nama: \(name)")
                isLoggedIn = true
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Apple Sign Up gagal: \(error.localizedDescription)")
        }
    }
}

// MARK: - Komponen reusable untuk field teks biasa
// Ini seperti membuat komponen <FormInput /> di React
struct FormField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(ThemeFont.caption)
                .foregroundColor(Color.textSecondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color.textSecondary)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
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
    }
}

#Preview {
    RegisterView()
}
