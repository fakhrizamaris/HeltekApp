//
//  SwiftCloudManager.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 11/03/26.
//
//  Ini adalah "backend service" kita.
//  Analoginya seperti file api.js di web development —
//  semua komunikasi ke database (CloudKit) lewat sini.
//

import Foundation
import CloudKit

// MARK: - Model User Profile
// Ini seperti interface/type di TypeScript
struct UserProfile {
    let userID: String      // ID unik dari Apple
    var name: String        // Nama lengkap
    var email: String       // Email (bisa kosong kalau user sembunyikan)
    var totalPoints: Int    // Total poin/baterai
    var createdAt: Date     // Tanggal pertama kali daftar
    
    // Konversi dari CKRecord (baris database) ke struct UserProfile kita
    // Ini seperti mapping response API ke object di JavaScript
    init(from record: CKRecord) {
        self.userID     = record["userID"] as? String ?? ""
        self.name       = record["name"] as? String ?? "User"
        self.email      = record["email"] as? String ?? ""
        self.totalPoints = record["totalPoints"] as? Int ?? 0
        self.createdAt  = record.creationDate ?? Date()
    }
    
    // Init manual (untuk buat profil baru)
    init(userID: String, name: String, email: String) {
        self.userID      = userID
        self.name        = name
        self.email       = email
        self.totalPoints = 0
        self.createdAt   = Date()
    }
}

// MARK: - CloudKit Manager (Singleton)
// Singleton = satu instance dipakai seluruh app
// Analoginya seperti koneksi database yang dibuka sekali, dipakai selamanya
class CloudKitManager {
    
    // Akses via CloudKitManager.shared — tidak perlu buat instance baru
    static let shared = CloudKitManager()
    
    // Database publik = semua user bisa baca/tulis
    // Analoginya: MySQL public table
    private let publicDB = CKContainer.default().publicCloudDatabase
    
    // Nama "tabel" di CloudKit disebut RecordType
    private let userRecordType = "UserProfile"
    
    private init() {}
    
    // MARK: - Cek apakah user sudah terdaftar
    // Analoginya: SELECT * FROM users WHERE userID = ?
    func fetchUserProfile(userID: String) async throws -> UserProfile? {
        
        // Predicate = kondisi WHERE di SQL
        let predicate = NSPredicate(format: "userID == %@", userID)
        
        // Query = SELECT statement
        let query = CKQuery(recordType: userRecordType, predicate: predicate)
        
        // Jalankan query ke CloudKit
        let result = try await publicDB.records(matching: query)
        
        // Ambil record pertama yang ditemukan
        let records = result.matchResults.compactMap { try? $1.get() }
        
        // Kalau ada → konversi ke UserProfile, kalau tidak ada → return nil
        if let record = records.first {
            print("✅ User ditemukan di CloudKit: \(userID)")
            return UserProfile(from: record)
        }
        
        print("ℹ️ User belum terdaftar di CloudKit: \(userID)")
        return nil
    }
    
    // MARK: - Buat profil baru di CloudKit
    // Analoginya: INSERT INTO users (userID, name, email, totalPoints) VALUES (...)
    func createUserProfile(profile: UserProfile) async throws {
        
        // Buat record baru — seperti baris baru di tabel
        let record = CKRecord(recordType: userRecordType)
        
        // Isi kolom-kolomnya
        record["userID"]       = profile.userID
        record["name"]         = profile.name
        record["email"]        = profile.email
        record["totalPoints"]  = profile.totalPoints
        
        // Simpan ke CloudKit
        try await publicDB.save(record)
        
        print("✅ Profil baru berhasil dibuat di CloudKit untuk: \(profile.name)")
    }
    
    // MARK: - Login atau Daftar (gabungan fetch + create)
    // Fungsi utama yang dipanggil saat Sign in with Apple
    // Analoginya: "upsert" — update kalau ada, insert kalau belum ada
    func loginOrRegister(
        userID: String,
        name: String,
        email: String
    ) async throws -> UserProfile {
        
        // Cek dulu apakah sudah pernah daftar
        if let existingProfile = try await fetchUserProfile(userID: userID) {
            // Sudah ada → pakai profil yang lama
            print("👋 Selamat datang kembali, \(existingProfile.name)!")
            return existingProfile
        }
        
        // Belum ada → buat profil baru
        let newProfile = UserProfile(
            userID: userID,
            name: name,
            email: email
        )
        try await createUserProfile(profile: newProfile)
        
        print("🎉 Selamat datang! Profil baru dibuat untuk \(name)")
        return newProfile
    }
}
