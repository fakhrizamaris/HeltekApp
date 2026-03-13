import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseStatsRepository: StatsRepository {
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    
    private var userID: String? {
        Auth.auth().currentUser?.uid
    }
    
    /// Helper: safely read a numeric value from Firestore data
    private func safeInt(from data: [String: Any], key: String) -> Int {
        if let val = data[key] as? Int { return val }
        if let val = data[key] as? Int64 { return Int(val) }
        if let val = data[key] as? NSNumber { return val.intValue }
        return 0
    }
    
    func fetchSummaryCards() async -> [StatsSummaryCard] {
        guard let uid = userID else {
            print("⚠️ fetchSummaryCards: no userID")
            return []
        }
        do {
            let doc = try await db.collection(usersCollection).document(uid).getDocument()
            let data = doc.data() ?? [:]
            
            let streak = safeInt(from: data, key: "streakCount")
            let totalEx = safeInt(from: data, key: "totalStretchCount")
            let totalMin = safeInt(from: data, key: "totalMinutesAllTime")
            
            print("✅ fetchSummaryCards: streak=\(streak), totalEx=\(totalEx), totalMin=\(totalMin)")
            
            return [
                StatsSummaryCard(
                    title: "Total Exercises",
                    value: "\(totalEx)",
                    subtitle: "All time",
                    systemImageName: "figure.walk"
                ),
                StatsSummaryCard(
                    title: "Current Streak",
                    value: "\(streak) days",
                    subtitle: "Keep it up",
                    systemImageName: "bolt.fill"
                )
            ]
        } catch {
            print("❌ fetchSummaryCards error:", error)
            return []
        }
    }
    
    func fetchStreakHistory() async -> [StreakHistoryItem] {
        guard let uid = userID else {
            print("⚠️ fetchStreakHistory: no userID")
            return []
        }
        var history: [StreakHistoryItem] = []
        
        do {
            let snapshot = try await db.collection(usersCollection).document(uid)
                .collection("dailyStats")
                .order(by: "date", descending: true)
                .limit(to: 7)
                .getDocuments()
            
            print("✅ fetchStreakHistory: found \(snapshot.documents.count) daily docs")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
            
            for doc in snapshot.documents {
                let data = doc.data()
                let dateStr = data["date"] as? String ?? doc.documentID
                let totalEx = safeInt(from: data, key: "totalExercise")
                
                if let date = formatter.date(from: dateStr) {
                    history.append(
                        StreakHistoryItem(
                            date: date,
                            goalCount: 3,
                            actualCount: totalEx
                        )
                    )
                }
            }
        } catch {
            print("❌ fetchStreakHistory error:", error)
        }
        return history
    }
    
    func fetchCalendarCounts() async -> [Date: Int] {
        guard let uid = userID else { return [:] }
        var counts: [Date: Int] = [:]
        
        do {
            let snapshot = try await db.collection(usersCollection).document(uid)
                .collection("dailyStats")
                .getDocuments()
                
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
            
            for doc in snapshot.documents {
                let data = doc.data()
                let dateStr = data["date"] as? String ?? doc.documentID
                let totalEx = safeInt(from: data, key: "totalExercise")
                
                if let date = formatter.date(from: dateStr) {
                    let startOfDay = Calendar.current.startOfDay(for: date)
                    counts[startOfDay] = totalEx
                }
            }
            print("✅ fetchCalendarCounts: \(counts.count) days")
        } catch {
            print("❌ fetchCalendarCounts error:", error)
        }
        return counts
    }
    
    func fetchChartData(period: StatsPeriod) async -> [StatsChartEntry] {
        guard let uid = userID else {
            print("⚠️ fetchChartData: no userID")
            return []
        }
        var entries: [StatsChartEntry] = []
        
        do {
            switch period {
            case .daily:
                let snapshot = try await db.collection(usersCollection).document(uid)
                    .collection("dailyStats")
                    .order(by: "date", descending: true)
                    .limit(to: 7)
                    .getDocuments()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "EEE"
                
                var tempEntries: [StatsChartEntry] = []
                for doc in snapshot.documents {
                    let data = doc.data()
                    let dateStr = data["date"] as? String ?? doc.documentID
                    let active = safeInt(from: data, key: "totalActive")
                    
                    if let date = formatter.date(from: dateStr) {
                        tempEntries.append(StatsChartEntry(label: displayFormatter.string(from: date), activeMinutes: active))
                    }
                }
                entries = tempEntries.reversed()
                print("✅ fetchChartData daily: \(entries.count) entries")
                
            case .weekly:
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "yyyy-MM"
                monthFormatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
                let currentMonth = monthFormatter.string(from: Date())
                
                let doc = try await db.collection(usersCollection).document(uid)
                    .collection("weeklyStats").document(currentMonth).getDocument()
                
                if let data = doc.data(), let weeksMap = data["weeks"] as? [String: Any] {
                    let sortedKeys = weeksMap.keys.sorted()
                    for key in sortedKeys {
                        if let weekData = weeksMap[key] as? [String: Any] {
                            let active = safeInt(from: weekData, key: "totalActive")
                            entries.append(StatsChartEntry(label: key, activeMinutes: active))
                        }
                    }
                }
                print("✅ fetchChartData weekly: \(entries.count) entries")
                
            case .monthly:
                let snapshot = try await db.collection(usersCollection).document(uid)
                    .collection("monthlyStats")
                    .getDocuments()
                    
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM"
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM"
                
                for doc in snapshot.documents {
                    let data = doc.data()
                    let active = safeInt(from: data, key: "totalActive")
                    
                    if let date = formatter.date(from: doc.documentID) {
                        let label = displayFormatter.string(from: date)
                        entries.append(StatsChartEntry(label: label, activeMinutes: active))
                    }
                }
                print("✅ fetchChartData monthly: \(entries.count) entries")
            }
        } catch {
            print("❌ fetchChartData error:", error)
        }
        return entries
    }
}
