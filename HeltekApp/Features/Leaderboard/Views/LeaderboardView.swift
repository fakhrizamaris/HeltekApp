//
//  LeaderboardView.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

//import SwiftUI
//
//struct LeaderboardView: View {
//    var body: some View {
//        VStack {
//            Text("Ini Leaderboard")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//        }
//    }
//}
//
//#Preview {
//    LeaderboardView()
//}

import SwiftUI

struct LeaderboardView: View {
    // Data Dummy (Mock Data) - Nanti ini yang ditarik dari Firebase
    let players = [
        Player(name: "Yipz", streakDays: 128, avatarName: "yipz_profile", globalRank: 1),
        Player(name: "Valen", streakDays: 92, avatarName: "brian_profile", globalRank: 2),
        Player(name: "Brian", streakDays: 88, avatarName: "fakhri_profile", globalRank: 3),
        Player(name: "Fakhri", streakDays: 76, avatarName: "fakhri_profile", globalRank: 4),
        Player(name: "Ammar", streakDays: 75, avatarName: "amar_profile", globalRank: 5),
        Player(name: "All", streakDays: 72, avatarName: "all_profile", globalRank: 6)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // 1. Tampilan Top 3 (Podium)
                HStack(alignment: .bottom, spacing: 20) {
                    PodiumView(player: players[1], rank: 2, color: Color.blue.opacity(0.1))
                    PodiumView(player: players[0], rank: 1, color: Color.white)
                        .scaleEffect(1.1) // Pemenang dibuat lebih besar
                    PodiumView(player: players[2], rank: 3, color: Color.yellow.opacity(0.1))
                }
                .padding(.top, 40)
                
                // 2. Kartu User Sendiri (Sesuai desain orange kamu)
                UserRankCard()
                
                // 3. Daftar Ranking Lainnya
                Text("NEARBY RANKINGS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .top])
                
                List(players.suffix(3)) { player in
                    HStack {
                        Text("\(player.globalRank)")
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .frame(width: 30)
                        
                        Image(systemName: "person.circle.fill") // Ganti image asli nanti
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            Text(player.name).fontWeight(.bold)
                            Text("\(player.streakDays) Days").font(.subheadline).foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Komponen Kecil: Podium untuk Top 3
struct PodiumView: View {
    let player: Player
    let rank: Int
    let color: Color
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
//                Image(systemName: "person.crop.circle.fill")
//                    .resizable()
//                    .frame(width: 70, height: 70)
                Image(player.avatarName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                Text("\(rank)")
                    .font(.caption2).bold()
                    .padding(5)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            Text(player.name).font(.system(size: 14, weight: .bold))
            Text("\(player.streakDays) Days").font(.system(size: 12)).foregroundColor(.red)
        }
        .padding()
        .background(color)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// Komponen Kecil: Kartu User (Orange)
struct UserRankCard: View {
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text("Eeyoo BRO (You)").fontWeight(.bold)
                Text("42 Day Streak").font(.subheadline)
            }
            Spacer()
            VStack {
                Text("#1,250").font(.title3).fontWeight(.bold)
                Text("GLOBAL RANK").font(.caption2)
            }
        }
        .padding()
        .background(Color.orange)
        .foregroundColor(.white)
        .cornerRadius(20)
        .padding()
    }
}



#Preview {
    LeaderboardView()
}
