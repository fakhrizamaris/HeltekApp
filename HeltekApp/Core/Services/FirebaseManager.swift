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

    // MARK: - Record Exercise Session
    // Update streak, total minutes, and total stretch counts (WIB timezone)
    func recordExerciseSession(durationSeconds: Int, stretches: Int) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        print("🟠 recordExerciseSession start for user: \(userID)")
        let timeZone = TimeZone(identifier: "Asia/Jakarta") ?? .current
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let now = Date()
        let dateKey = Self.dateKey(from: now, calendar: calendar)
        let monthKey = Self.monthKey(from: now, calendar: calendar)
        let weekOfMonth = calendar.component(.weekOfMonth, from: now)
        let weekKey = "W\(weekOfMonth)"

        let durationMinutes = max(1, durationSeconds / 60)

        let userRef = db.collection(usersCollection).document(userID)
        let dailyRef = userRef.collection("dailyStats").document(dateKey)
        let weeklyRef = userRef.collection("weeklyStats").document(monthKey)
        let monthlyRef = userRef.collection("monthlyStats").document(monthKey)

        // 1) Update user streak & totals atomically
        try await db.runTransaction { transaction, errorPointer in
            let userDoc: DocumentSnapshot
            do {
                userDoc = try transaction.getDocument(userRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            let lastStreakDate = userDoc.data()?["lastStreakDate"] as? String
            let currentStreak = userDoc.data()?["streakCount"] as? Int ?? 0
            let yesterdayKey = Self.dateKey(from: calendar.date(byAdding: .day, value: -1, to: now) ?? now, calendar: calendar)

            let updatedStreak: Int
            if lastStreakDate == dateKey {
                updatedStreak = currentStreak
            } else if lastStreakDate == yesterdayKey {
                updatedStreak = currentStreak + 1
            } else {
                updatedStreak = 1
            }

            // Writes only after all reads are done
            transaction.setData([
                "id": userID,
                "lastStreakDate": dateKey,
                "streakCount": updatedStreak,
                "totalMinutesAllTime": FieldValue.increment(Int64(durationMinutes)),
                "totalStretchCount": FieldValue.increment(Int64(stretches)),
                "updatedAt": Timestamp(date: now)
            ], forDocument: userRef, merge: true)

            return nil
        }

        // 2) Update daily/weekly/monthly aggregates (non-transactional)
        let dailyPath = dailyRef.path
        let weeklyPath = weeklyRef.path
        let monthlyPath = monthlyRef.path
        print("🟠 writing dailyStats: \(dailyPath)")
        print("🟠 writing weeklyStats: \(weeklyPath)")
        print("🟠 writing monthlyStats: \(monthlyPath)")

        try await dailyRef.setData([
            "date": dateKey,
            "didExercise": true,
            "totalActive": FieldValue.increment(Int64(durationMinutes)),
            "totalExercise": FieldValue.increment(Int64(stretches))
        ], merge: true)
        let dailySnapshot = try await dailyRef.getDocument(source: .server)
        print("✅ dailyStats exists on server: \(dailySnapshot.exists)")

        let weeklyDoc = try await weeklyRef.getDocument()
        if !weeklyDoc.exists {
            try await weeklyRef.setData([
                "weeks": [
                    "W1": ["totalActive": 0, "totalExercise": 0],
                    "W2": ["totalActive": 0, "totalExercise": 0],
                    "W3": ["totalActive": 0, "totalExercise": 0],
                    "W4": ["totalActive": 0, "totalExercise": 0],
                    "W5": ["totalActive": 0, "totalExercise": 0]
                ]
            ], merge: true)
        }

        try await weeklyRef.updateData([
            FieldPath(["weeks", weekKey, "totalActive"]): FieldValue.increment(Int64(durationMinutes)),
            FieldPath(["weeks", weekKey, "totalExercise"]): FieldValue.increment(Int64(stretches))
        ])
        let weeklySnapshot = try await weeklyRef.getDocument(source: .server)
        print("✅ weeklyStats exists on server: \(weeklySnapshot.exists)")

        try await monthlyRef.setData([
            "totalActive": FieldValue.increment(Int64(durationMinutes)),
            "totalExercise": FieldValue.increment(Int64(stretches))
        ], merge: true)
        let monthlySnapshot = try await monthlyRef.getDocument(source: .server)
        print("✅ monthlyStats exists on server: \(monthlySnapshot.exists)")

        print("✅ recordExerciseSession done: daily=\(dateKey) weekly=\(monthKey)/\(weekKey) monthly=\(monthKey)")
    }

    private static func dateKey(from date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func monthKey(from date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }

    // MARK: - Ambil streak count user saat ini
    func fetchCurrentUserStreakCount() async throws -> Int {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        let doc = try await db
            .collection(usersCollection)
            .document(userID)
            .getDocument()
        return doc.data()?["streakCount"] as? Int ?? 0
    }
    
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
            try await ensureUserStatsDefaults(userID: userID)
            
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
            try await ensureUserStatsDefaults(userID: userID)
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
    
    // MARK: - Simpan Detail Profil User (Data Diri Lengkap)
    // Menyimpan data profil lengkap ke dokumen user yang sama di Firestore
    // merge: true = hanya update field ini, TIDAK hapus totalPoints, createdAt, dll
    func saveUserDetailProfile(profile: UserProfile) async throws {
        let docRef = db.collection(usersCollection).document(profile.id)
        
        try await docRef.setData([
            "fullName":          profile.fullName,
            "age":               profile.age,
            "bio":               profile.bio,
            "occupation":        profile.occupation,
            "dailySittingHours": profile.dailySittingHours,
            "profileCompleted":  true,
            "updatedAt":         Timestamp(date: Date()),
            // Update juga field 'name' supaya konsisten dengan leaderboard
            "name":              profile.fullName
        ], merge: true)
        try await ensureUserStatsDefaults(userID: profile.id)
        
        print("✅ Detail profil berhasil disimpan untuk: \(profile.fullName)")
    }

    // MARK: - Ensure user stats defaults exist
    func ensureUserStatsDefaults(userID: String) async throws {
        let docRef = db.collection(usersCollection).document(userID)
        try await docRef.setData([
            "streakCount": 0,
            "lastStreakDate": "",
            "totalStretchCount": 0,
            "totalMinutesAllTime": 0
        ], merge: true)
    }
    
    // MARK: - Ambil Detail Profil User
    // Analoginya: SELECT fullName, age, bio, occupation, ... FROM users WHERE id = ?
    func fetchUserDetailProfile(userID: String) async throws -> UserProfile? {
        let doc = try await db
            .collection(usersCollection)
            .document(userID)
            .getDocument()
        
        guard let data = doc.data() else { return nil }
        
        // Cek apakah profil sudah pernah diisi
        let profileCompleted = data["profileCompleted"] as? Bool ?? false
        guard profileCompleted else { return nil }
        
        return UserProfile(
            id:                userID,
            fullName:          data["fullName"] as? String ?? data["name"] as? String ?? "",
            age:               data["age"] as? Int ?? 0,
            bio:               data["bio"] as? String ?? "",
            occupation:        data["occupation"] as? String ?? "",
            dailySittingHours: data["dailySittingHours"] as? Int ?? 0,
            profileCompleted:  true,
            createdAt:         (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt:         (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    // MARK: - Cek apakah profil user sudah lengkap
    // Dipanggil di HeltekAppApp untuk menentukan flow navigasi
    func isProfileCompleted(userID: String) async -> Bool {
        do {
            let doc = try await db
                .collection(usersCollection)
                .document(userID)
                .getDocument()
            
            return doc.data()?["profileCompleted"] as? Bool ?? false
        } catch {
            print("❌ Gagal cek profil: \(error.localizedDescription)")
            return false
        }
    }
}
