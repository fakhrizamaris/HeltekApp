//
//  UserProfile.swift
//  HeltekApp
//
//  Model data diri user yang target-nya orang dengan Sedentary Lifestyle.
//  Struct ini merepresentasikan profil lengkap user di Firestore.
//

import Foundation

// MARK: - User Profile Model
struct UserProfile: Codable, Identifiable {
    var id: String              // Firebase User ID
    var fullName: String        // Nama lengkap
    var age: Int                // Umur user
    var bio: String             // Data diri / bio singkat
    var occupation: String      // Pekerjaan
    var dailySittingHours: Int  // Berapa jam duduk per hari (relevan untuk target Sedentary)
    var profileCompleted: Bool  // Flag apakah profil sudah diisi
    var createdAt: Date         // Kapan profil dibuat
    var updatedAt: Date         // Kapan profil terakhir diupdate
    
    // Default initializer untuk user baru
    static func empty(userID: String) -> UserProfile {
        UserProfile(
            id: userID,
            fullName: "",
            age: 0,
            bio: "",
            occupation: "",
            dailySittingHours: 0,
            profileCompleted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Daftar Pekerjaan Sedentary
// Pilihan pekerjaan yang umum untuk target user (Sedentary Lifestyle)
enum OccupationType: String, CaseIterable {
    case programmer = "Programmer / Developer"
    case designer = "Designer"
    case dataEntry = "Data Entry"
    case writer = "Penulis / Content Writer"
    case accountant = "Akuntan / Finance"
    case admin = "Staff Admin / Office"
    case student = "Mahasiswa / Pelajar"
    case gamer = "Gamer"
    case callCenter = "Customer Service / Call Center"
    case researcher = "Peneliti / Akademisi"
    case other = "Lainnya"
}

// MARK: - Daftar Durasi Duduk Per Hari
enum SittingDuration: Int, CaseIterable {
    case lessThan4 = 3
    case fourToSix = 5
    case sixToEight = 7
    case eightToTen = 9
    case moreThan10 = 11
    
    var label: String {
        switch self {
        case .lessThan4:  return "< 4 jam"
        case .fourToSix:  return "4 - 6 jam"
        case .sixToEight: return "6 - 8 jam"
        case .eightToTen: return "8 - 10 jam"
        case .moreThan10: return "> 10 jam"
        }
    }
    
    // SF Symbol name — dipakai sebagai Image(systemName:)
    var icon: String {
        switch self {
        case .lessThan4:  return "checkmark.shield.fill"
        case .fourToSix:  return "exclamationmark.triangle.fill"
        case .sixToEight: return "exclamationmark.triangle.fill"
        case .eightToTen: return "flame.fill"
        case .moreThan10: return "bolt.trianglebadge.exclamationmark.fill"
        }
    }
    
    // Warna icon berdasarkan risiko
    var iconColorName: String {
        switch self {
        case .lessThan4:  return "green"
        case .fourToSix:  return "yellow"
        case .sixToEight: return "orange"
        case .eightToTen: return "red"
        case .moreThan10: return "red"
        }
    }
    
    var riskLevel: String {
        switch self {
        case .lessThan4:  return "Risiko Rendah"
        case .fourToSix:  return "Risiko Sedang"
        case .sixToEight: return "Risiko Cukup Tinggi"
        case .eightToTen: return "Risiko Tinggi"
        case .moreThan10: return "Risiko Sangat Tinggi"
        }
    }
}
