//
//  LeaderboardViewModel.swift
//  HeltekApp
//
//  Created by Muhammad Ammar Farisi on 14/03/26.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class LeaderboardViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var currentUser: Player?
//    previousRankOrder: [String]
    
    private var db = Firestore.firestore()
    
    // Simpan urutan rank sebelumnya untuk hitung trend
    private var previousRankOrder: [String] = []
    
    func fetchData() {
            guard let currentUID = Auth.auth().currentUser?.uid else { return }
            
            db.collection("users").order(by: "streakCount", descending: true)
                .addSnapshotListener { (querySnapshot, error) in
                    guard let documents = querySnapshot?.documents else { return }
                    
                    let allPlayers = documents.map { doc -> Player in
                        let data = doc.data()
                        let isMe = doc.documentID == currentUID // Cek apakah ini ID saya?
                        
                        let player = Player(
                            id: doc.documentID,
                            name: data["fullName"] as? String ?? "No Name",
                            points: data["streakCount"] as? Int ?? 0,
                            avatarName: "person.circle.fill",
                            occupation: data["occupation"] as? String ?? "",
                            isCurrentUser: isMe
                        )
                        
                        if isMe { self.currentUser = player } // Simpan data saya
                        return player
                    }
                    
                    self.players = allPlayers
                }
    }
}
