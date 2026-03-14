import Foundation
import FirebaseFirestore

class LeaderboardViewModel: ObservableObject {
    @Published var players: [Player] = []
    private var db = Firestore.firestore()
    
    func fetchData() {
        // TANYA TEMANMU: Apa nama collection-nya? (Contoh di bawah memakai "users")
        db.collection("users").order(by: "streakDays", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else { return }
                
                self.players = documents.map { doc -> Player in
                    let data = doc.data()
                    return Player(
                        name: data["name"] as? String ?? "No Name",
                        streakDays: data["streakDays"] as? Int ?? 0,
                        avatarName: data["avatarName"] as? String ?? "default_avatar",
                        globalRank: data["globalRank"] as? Int ?? 0
                    )
                }
            }
    }
}