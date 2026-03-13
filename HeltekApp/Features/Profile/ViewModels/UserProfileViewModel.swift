//
//  UserProfileViewModel.swift
//  HeltekApp
//
//  ViewModel untuk mengelola pengisian dan penyimpanan profil user.
//  Saat ini hanya meminta nama/username.
//

import SwiftUI
import Combine

@MainActor
class UserProfileViewModel: ObservableObject {
    
    // MARK: - Form Fields
    @Published var fullName: String = ""
    
    // MARK: - State
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // Flag profil selesai — disimpan di AppStorage
    @AppStorage("hasCompletedProfile") var hasCompletedProfile = false
    @AppStorage("userID") var userID = ""
    @AppStorage("userName") var userName = ""
    
    private let firebase = FirebaseManager.shared
    
    // MARK: - Validasi Nama
    var isNameValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Simpan Profil ke Firestore
    func saveProfile() async {
        guard isNameValid else { return }
        
        isLoading = true
        showError = false
        
        let profile = UserProfile(
            id: userID,
            fullName: fullName,
            profileCompleted: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            try await firebase.saveUserDetailProfile(profile: profile)
            
            // Update AppStorage
            userName = fullName
            hasCompletedProfile = true
            
            print("✅ Profil berhasil disimpan untuk user: \(fullName)")
            
            isLoading = false
            
        } catch {
            isLoading = false
            errorMessage = "Gagal menyimpan profil: \(error.localizedDescription)"
            showError = true
            print("❌ Gagal simpan profil: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load existing profile (for edit)
    func loadExistingProfile() async {
        guard !userID.isEmpty else { return }
        
        do {
            if let profile = try await firebase.fetchUserDetailProfile(userID: userID) {
                self.fullName = profile.fullName
            }
        } catch {
            print("❌ Gagal load profil: \(error.localizedDescription)")
        }
    }
}
