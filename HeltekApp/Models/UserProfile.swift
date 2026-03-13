//
//  UserProfile.swift
//  HeltekApp
//
//  Model data diri user.
//  Saat ini hanya menyimpan nama karena fitur lain masih dalam tahap riset.
//

import Foundation

// MARK: - User Profile Model
struct UserProfile: Codable, Identifiable {
    var id: String              // Firebase User ID
    var fullName: String        // Nama lengkap / username
    var profileCompleted: Bool  // Flag apakah profil sudah diisi
    var createdAt: Date         // Kapan profil dibuat
    var updatedAt: Date         // Kapan profil terakhir diupdate
    
    // Default initializer untuk user baru
    static func empty(userID: String) -> UserProfile {
        UserProfile(
            id: userID,
            fullName: "",
            profileCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
