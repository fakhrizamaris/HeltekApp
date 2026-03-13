//
//  UserProfileViewModel.swift
//  HeltekApp
//
//  ViewModel untuk mengelola pengisian dan penyimpanan profil user.
//  Digunakan di UserProfileSetupView (setelah login/register).
//

import SwiftUI
import Combine

@MainActor
class UserProfileViewModel: ObservableObject {
    
    // MARK: - Form Fields
    @Published var fullName: String = ""
    @Published var age: String = ""               // String karena input dari TextField
    @Published var bio: String = ""
    @Published var selectedOccupation: OccupationType = .programmer
    @Published var selectedSittingDuration: SittingDuration = .sixToEight
    @Published var customOccupation: String = ""  // Jika pilih "Lainnya"
    
    // MARK: - State
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var currentStep = 0  // Untuk step-by-step form (0, 1, 2, 3)
    
    // Flag profil selesai — disimpan di AppStorage
    @AppStorage("hasCompletedProfile") var hasCompletedProfile = false
    @AppStorage("userID") var userID = ""
    @AppStorage("userName") var userName = ""
    
    private let firebase = FirebaseManager.shared
    
    let totalSteps = 4
    
    // MARK: - Validasi Per Step
    var isCurrentStepValid: Bool {
        switch currentStep {
        case 0: // Nama
            return !fullName.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: // Umur
            guard let ageInt = Int(age), ageInt >= 10, ageInt <= 100 else { return false }
            return true
        case 2: // Pekerjaan
            if selectedOccupation == .other {
                return !customOccupation.trimmingCharacters(in: .whitespaces).isEmpty
            }
            return true
        case 3: // Durasi duduk (selalu valid karena sudah ada default)
            return true
        default:
            return false
        }
    }
    
    // MARK: - Navigasi Step
    func nextStep() {
        guard isCurrentStepValid else { return }
        if currentStep < totalSteps - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep += 1
            }
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep -= 1
            }
        }
    }
    
    // MARK: - Simpan Profil ke Firestore
    func saveProfile() async {
        guard isCurrentStepValid else { return }
        
        isLoading = true
        showError = false
        
        let occupation = selectedOccupation == .other
            ? customOccupation
            : selectedOccupation.rawValue
        
        let ageInt = Int(age) ?? 0
        
        let profile = UserProfile(
            id: userID,
            fullName: fullName,
            age: ageInt,
            bio: bio,
            occupation: occupation,
            dailySittingHours: selectedSittingDuration.rawValue,
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
                self.age = profile.age > 0 ? "\(profile.age)" : ""
                self.bio = profile.bio
                self.customOccupation = profile.occupation
                
                // Match occupation type
                if let matched = OccupationType.allCases.first(where: { $0.rawValue == profile.occupation }) {
                    self.selectedOccupation = matched
                } else {
                    self.selectedOccupation = .other
                    self.customOccupation = profile.occupation
                }
                
                // Match sitting duration
                if let matched = SittingDuration.allCases.first(where: { $0.rawValue == profile.dailySittingHours }) {
                    self.selectedSittingDuration = matched
                }
            }
        } catch {
            print("❌ Gagal load profil: \(error.localizedDescription)")
        }
    }
}
