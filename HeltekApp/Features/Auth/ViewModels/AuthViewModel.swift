//
//  AuthViewModel.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 11/03/26.
//

import SwiftUI
import Combine
import FirebaseAuth
import AuthenticationServices
import CryptoKit  // untuk generate nonce (keamanan)

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userName")   var userName = ""
    @AppStorage("userEmail")  var userEmail = ""
    @AppStorage("userID")     var userID = ""
    @AppStorage("hasCompletedProfile") var hasCompletedProfile = false
    
    // Nonce = string acak untuk keamanan — wajib ada untuk Apple Sign In
    // Analoginya seperti CSRF token di web
    private var currentNonce: String?
    
    private let firebase = FirebaseManager.shared
    
    init() {}
    
    // MARK: - Prepare Apple Sign In Request
    // Dipanggil SEBELUM sheet Apple muncul
    func prepareAppleSignIn(request: ASAuthorizationAppleIDRequest) {
        // Generate nonce baru setiap request
        let nonce = randomNonceString()
        currentNonce = nonce
        
        request.requestedScopes = [.fullName, .email]
        
        // Kirim nonce yang sudah di-hash ke Apple
        request.nonce = sha256(nonce)
    }
    
    // MARK: - Handle hasil Sign in with Apple
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
            
        case .success(let authorization):
            guard let credential = authorization.credential
                    as? ASAuthorizationAppleIDCredential else { return }
            
            guard let nonce = currentNonce else {
                handleError("Nonce tidak ditemukan — coba lagi")
                return
            }
            
            guard let appleIDToken = credential.identityToken,
                  let tokenString = String(data: appleIDToken, encoding: .utf8) else {
                handleError("Gagal membaca token dari Apple")
                return
            }
            
            // Buat credential Firebase dari token Apple
            let firebaseCredential = OAuthProvider.appleCredential(
                withIDToken: tokenString,
                rawNonce: nonce,
                fullName: credential.fullName
            )
            
            // Nama dari Apple — hanya ada di login pertama
            let firstName = credential.fullName?.givenName ?? ""
            let lastName  = credential.fullName?.familyName ?? ""
            let fullName  = "\(firstName) \(lastName)"
                .trimmingCharacters(in: .whitespaces)
            let appleEmail = credential.email ?? ""
            
            print("🍎 Apple token diterima, proses login ke Firebase...")
            
            // Login ke Firebase dengan credential dari Apple
            Task {
                await signInToFirebase(
                    credential: firebaseCredential,
                    name: fullName,
                    email: appleEmail
                )
            }
            
        case .failure(let error):
            handleError("Apple Sign In gagal: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Login ke Firebase
    private func signInToFirebase(
        credential: OAuthCredential,
        name: String,
        email: String
    ) async {
        isLoading = true
        
        do {
            // Auth ke Firebase — seperti POST /login ke server
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            
            print("🔥 Firebase Auth berhasil! UID: \(firebaseUser.uid)")
            
            // Nama final — pakai dari Apple, atau dari Firebase, atau default
            let finalName = name.isEmpty
                ? (firebaseUser.displayName ?? (userName.isEmpty ? "User" : userName))
                : name
            
            let finalEmail = email.isEmpty
                ? (firebaseUser.email ?? userEmail)
                : email
            
            // Simpan atau update profil di Firestore
            try await firebase.saveUserProfile(
                userID: firebaseUser.uid,
                name: finalName,
                email: finalEmail
            )
            
            // Simpan ke AppStorage — persisten di HP
            userID    = firebaseUser.uid
            userName  = finalName
            userEmail = finalEmail
            
            // Cek apakah profil sudah lengkap di Firestore
            let profileDone = await firebase.isProfileCompleted(userID: firebaseUser.uid)
            hasCompletedProfile = profileDone
            
            print("✅ Login berhasil! Selamat datang, \(finalName). Profil lengkap: \(profileDone)")
            
            isLoading = false
            
            // Pindah ke flow berikutnya (profil setup atau MainTabView)
            isLoggedIn = true
            
        } catch {
            isLoading = false
            handleError("Login gagal: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Register dengan Email & Password
    func registerWithEmail(name: String, email: String, password: String) async {
        isLoading = true
        showError = false
        
        do {
            // 1. Buat user di Firebase Auth
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let firebaseUser = authResult.user
            
            print("🚀 Registrasi Firebase Auth berhasil! UID: \(firebaseUser.uid)")
            
            // 2. Simpan profil ke Firestore via FirebaseManager
            try await firebase.saveUserProfile(
                userID: firebaseUser.uid,
                name: name,
                email: email
            )
            
            // 3. Simpan ke AppStorage (Sesuai dengan cara kamu menyimpan State)
            self.userID = firebaseUser.uid
            self.userName = name
            self.userEmail = email
            
            // User baru = profil belum diisi
            self.hasCompletedProfile = false
            
            print("✅ Registrasi berhasil! Selamat datang, \(name). Lanjut isi profil...")
            
            isLoading = false
            
            // 4. Ubah flag login — akan diarahkan ke UserProfileSetupView
            isLoggedIn = true
            
        } catch {
            isLoading = false
            handleError("Registrasi gagal: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Login dengan Email & Password
    func loginWithEmail(email: String, password: String) async {
        isLoading = true
        showError = false
        
        do {
            // 1. Verifikasi kredensial di Firebase Auth
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let firebaseUser = authResult.user
            
            print("🔥 Login Email Auth berhasil! UID: \(firebaseUser.uid)")
            
            // 2. Ambil data dari Firestore untuk mendapatkan Nama User
            if let userProfile = try await firebase.fetchUserProfile(userID: firebaseUser.uid) {
                self.userName = userProfile.name
                self.userEmail = userProfile.email
            } else {
                // Berjaga-jaga jika dokumen profil tidak ada
                self.userName = "User"
                self.userEmail = email
            }
            
            self.userID = firebaseUser.uid
            
            // Cek apakah profil sudah lengkap
            let profileDone = await firebase.isProfileCompleted(userID: firebaseUser.uid)
            self.hasCompletedProfile = profileDone
            
            isLoading = false
            
            // 3. Ubah flag login — flow selanjutnya tergantung status profil
            isLoggedIn = true
            
        } catch {
            isLoading = false
            handleError("Login gagal: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            hasCompletedProfile = false
            userID = ""
            userName = ""
            userEmail = ""
            print("👋 Logout berhasil")
        } catch {
            print("❌ Logout gagal: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error handler
    private func handleError(_ message: String) {
        print("❌ \(message)")
        errorMessage = message
        showError = true
        isLoading = false
    }
    
    // MARK: - Generate random nonce (keamanan Apple Sign In)
    // Ini kode standar dari dokumentasi Apple — tidak perlu diubah
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Gagal generate nonce: \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    // MARK: - Hash nonce pakai SHA256
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}
