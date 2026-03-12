//
//  FirebaseManager.swift
//  HeltekApp
//
//  Created by Fakhri Djamaris on 12/03/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

// MARK: - Model User untuk Leaderboard
struct HeltekUser: Identifiable, Codable {
    var id: String          // Firebase User ID
    var name: String        // Nama user
    var email: String       // Email
    var totalPoints: Int    // Total poin — untuk ranking
    var createdAt: Date     // Tanggal daftar
    
    // Computed property — rank dihitung di View, bukan disimpan
    // supaya tidak perlu update semua data kalau ada yang berubah
    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? "?"
        let last = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }
}

// MARK: - Firebase Manager Singleton
class FirebaseManager: ObservableObject {
    
    
    // Satu instance dipakai seluruh app
    static let shared = FirebaseManager()
    
    // Koneksi ke Firestore — seperti koneksi MySQL
    private let db = Firestore.firestore()
    
    // Nama "tabel" di Firestore
    private let usersCollection = "users"
    
    // Published = UI otomatis update kalau data ini berubah
    @Published var leaderboard: [HeltekUser] = []
    @Published var isLoadingLeaderboard = false
    
    private init() {}
    
    // MARK: - Simpan atau Update profil user
    // Analoginya: INSERT ... ON DUPLICATE KEY UPDATE di MySQL
    func saveUserProfile(
        userID: String,
        name: String,
        email: String
    ) async throws {
        
        // Cek apakah user sudah ada
        let docRef = db.collection(usersCollection).document(userID)
        let doc = try await docRef.getDocument()
        
        if doc.exists {
            // User lama — hanya update nama kalau sebelumnya kosong
            // Tidak reset poin!
            if let existingName = doc.data()?["name"] as? String,
               existingName.isEmpty && !name.isEmpty {
                try await docRef.updateData(["name": name])
            }
            print("👋 User lama ditemukan di Firebase: \(userID)")
            
        } else {
            // User baru — buat dokumen baru
            // setData = INSERT INTO users VALUES (...)
            try await docRef.setData([
                "id":           userID,
                "name":         name,
                "email":        email,
                "totalPoints":  0,
                "createdAt":    Timestamp(date: Date())
            ])
            print("🎉 User baru dibuat di Firebase: \(name)")
        }
    }
    
    // MARK: - Ambil data profil satu user
    // Analoginya: SELECT * FROM users WHERE id = ?
    func fetchUserProfile(userID: String) async throws -> HeltekUser? {
        let doc = try await db
            .collection(usersCollection)
            .document(userID)
            .getDocument()
        
        guard let data = doc.data() else { return nil }
        
        return HeltekUser(
            id:           data["id"] as? String ?? userID,
            name:         data["name"] as? String ?? "User",
            email:        data["email"] as? String ?? "",
            totalPoints:  data["totalPoints"] as? Int ?? 0,
            createdAt:    (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    // MARK: - Update poin user setelah exercise
    // Analoginya: UPDATE users SET totalPoints = totalPoints + ? WHERE id = ?
    func addPoints(userID: String, points: Int) async throws {
        let docRef = db.collection(usersCollection).document(userID)
        
        // increment = tambah nilai tanpa perlu baca dulu
        // Lebih aman dari race condition (2 device update bersamaan)
        try await docRef.updateData([
            "totalPoints": FieldValue.increment(Int64(points))
        ])
        
        print("✅ +\(points) poin ditambahkan untuk user: \(userID)")
    }
    
    // MARK: - Ambil Top 10 Leaderboard
    // Analoginya: SELECT * FROM users ORDER BY totalPoints DESC LIMIT 10
    @MainActor
    func fetchLeaderboard() async {
        isLoadingLeaderboard = true
        
        do {
            let snapshot = try await db
                .collection(usersCollection)
                .order(by: "totalPoints", descending: true) // Sort tertinggi dulu
                .limit(to: 10)                               // Ambil top 10 saja
                .getDocuments()
            
            // Map setiap dokumen ke struct HeltekUser
            // Analoginya: .map() di JavaScript
            let users = snapshot.documents.compactMap { doc -> HeltekUser? in
                let data = doc.data()
                return HeltekUser(
                    id:           data["id"] as? String ?? doc.documentID,
                    name:         data["name"] as? String ?? "User",
                    email:        data["email"] as? String ?? "",
                    totalPoints:  data["totalPoints"] as? Int ?? 0,
                    createdAt:    (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
            }
            
            // Update UI langsung
            self.leaderboard = users
            self.isLoadingLeaderboard = false
            
            print("✅ Leaderboard berhasil diambil: \(users.count) user")
            
        } catch {
            self.isLoadingLeaderboard = false
            print("❌ Gagal ambil leaderboard: \(error.localizedDescription)")
        }
    }
}

