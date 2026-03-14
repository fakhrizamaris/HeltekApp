//
//  LeaderboardView.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.

import SwiftUI

// MARK: - LeaderboardView (Main)

struct LeaderboardView: View {
    @StateObject var viewModel = LeaderboardViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: Podium Section
                    if viewModel.players.count >= 3 {
                        HStack(alignment: .bottom, spacing: 10) {
                            PodiumView(player: viewModel.players[1], rank: 2, boxHeight: 120)
                            PodiumView(player: viewModel.players[0], rank: 1, boxHeight: 150)
                                .zIndex(1)
                            PodiumView(player: viewModel.players[2], rank: 3, boxHeight: 120)
                        }
                        .clipped()  // TAMBAH — clip semua yang keluar dari HStack
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 28)
                    } else {
                        ProgressView("Loading Ranking...")
                            .frame(height: 200)
                    }

                    // MARK: Current User Rank Card
                    let myRank = (viewModel.players.firstIndex(where: { $0.isCurrentUser }) ?? 0) + 1
                    UserRankCard(user: viewModel.currentUser, rank: myRank)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 28)

                    // MARK: Nearby Rankings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("NEARBY RANKINGS")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(.systemGray))
                            .tracking(0.8)
                            .padding(.horizontal, 16)

                        VStack(spacing: 10) {
                            ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                                if index >= 3 {
                                    NearbyRankRow(player: player, rank: index + 1)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea())
            .onAppear {
                viewModel.fetchData()
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - PodiumView

struct PodiumView: View {
    let player: Player
    let rank: Int
    let boxHeight: CGFloat

    // Warna background circle di belakang avatar — beda tiap rank
    var avatarBgColor: Color {
        switch rank {
        case 1: return Color(red: 1.0,  green: 0.87, blue: 0.28) // Gold/kuning
        case 2: return Color(red: 0.71, green: 0.86, blue: 1.0)  // Biru muda
        default: return Color(red: 1.0,  green: 0.91, blue: 0.65) // Krem hangat
        }
    }

    // Warna border lingkaran avatar — beda tiap rank
    var avatarBorderColor: Color {
        switch rank {
        case 1: return Color(red: 0.97, green: 0.76, blue: 0.10) // Gold
        case 2: return Color(red: 0.55, green: 0.76, blue: 0.96) // Biru
        default: return Color(red: 0.85, green: 0.71, blue: 0.44) // Krem tua
        }
    }

    // Warna background kotak konten — match dengan warna circle
    var boxBgColor: Color {
        switch rank {
        case 1: return Color.white
        case 2: return Color(red: 0.90, green: 0.94, blue: 0.99) // Biru muda soft
        default: return Color(red: 1.0,  green: 0.97, blue: 0.88) // Krem soft
        }
    }

    var avatarSize: CGFloat   { rank == 1 ? 76 : 62 }
    var bgCircleSize: CGFloat { rank == 1 ? 89 : 73 }
    // Seberapa tipis bagian bawah avatar "masuk" ke kotak
    let peekIntoBox: CGFloat = -10

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Crown khusus rank 1
            if rank == 1 {
                Image(systemName: "crown.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.97, green: 0.76, blue: 0.10))
                    .frame(height: 22)
                    .padding(.bottom, 4)
            } else {
                Spacer().frame(height: 26)
            }

            // MARK: Avatar — sepenuhnya di LUAR kotak
            ZStack {
                // Background circle
                Circle()
                    .fill(avatarBgColor)
                    .frame(width: bgCircleSize, height: bgCircleSize)

                // Avatar foto tepat di tengah circle
                AvatarImage(name: player.avatarName, size: avatarSize)
                    .overlay(
                        Circle().stroke(avatarBorderColor, lineWidth: rank == 1 ? 3 : 2)
                    )

                // Badge nomor menempel di tepi kanan bawah avatar
                Text("\(rank)")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(
                        x: avatarSize / 2 - 2,
                        y: avatarSize / 2 - 2
                    )
            }
            .frame(width: bgCircleSize, height: bgCircleSize)
            // Negative padding = ujung bawah circle tipis masuk ke kotak
            .padding(.bottom, -peekIntoBox)
            .zIndex(1)

            // MARK: Kotak konten di BAWAH avatar
            VStack(spacing: 3) {
                Spacer().frame(height: peekIntoBox + 25)

                Text(player.name)
                    .font(.system(size: rank == 1 ? 15 : 13, weight: .heavy))
                    .foregroundColor(Color(red: 0.08, green: 0.08, blue: 0.18))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 6)

                Text("\(player.points) Days")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: boxHeight)
            .background(boxBgColor)
//            .cornerRadius(18)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 18,
                    bottomLeadingRadius: rank == 1 ? 18 : 0,
                    bottomTrailingRadius: rank == 1 ? 18 : 0,
                    topTrailingRadius: 18
                )
            )
            .shadow(color: Color.black.opacity(0.07), radius: 12, x: 0, y: 5)
        }
    }
}

// MARK: - UserRankCard

struct UserRankCard: View {
    let user: Player?
    let rank: Int

    var body: some View {
        HStack(spacing: 14) {

            // Avatar: lingkaran putih transparan + icon person di dalam
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.28))
                    .frame(width: 58, height: 58)

                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(.white)
            }

            // Nama & poin
            VStack(alignment: .leading, spacing: 3) {
                Text("\(user?.name ?? "Guest") (You)")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(user?.points ?? 0) Points")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.88))
            }

            Spacer()

            // Global rank
            VStack(alignment: .trailing, spacing: 2) {
                Text("#\(rank)")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.white)

                Text("GLOBAL RANK")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white.opacity(0.80))
                    .tracking(0.5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color(red: 0.98, green: 0.44, blue: 0.10))
        .cornerRadius(22)
        // Shadow oranye besar di bawah card
        .shadow(color: Color(red: 0.98, green: 0.44, blue: 0.10).opacity(0.45), radius: 22, x: 0, y: 10)
    }
}

// MARK: - NearbyRankRow

struct NearbyRankRow: View {
    let player: Player
    let rank: Int

    // Arrow icon berdasarkan trend dari model
    @ViewBuilder
    var trendView: some View {
        switch player.trend {
        case .up:
            Image(systemName: "arrow.up.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.green)
        case .down:
            Image(systemName: "arrow.down.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.red)
        case .neutral:
            Rectangle()
                .frame(width: 14, height: 2.5)
                .foregroundColor(Color(.systemGray3))
                .cornerRadius(2)
        }
    }

    var body: some View {
        HStack(spacing: 12) {

            // Nomor rank
            Text("\(rank)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(.systemGray2))
                .frame(width: 28, alignment: .leading)

            // Avatar
            AvatarImage(name: player.avatarName, size: 46)

            // Nama & poin
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.08, blue: 0.18))

                Text("\(player.points) Days")
                    .font(.system(size: 13))
                    .foregroundColor(Color(.systemGray))
            }

            Spacer()

            // Trend arrow
            trendView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - AvatarImage

struct AvatarImage: View {
    let name: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.87, green: 0.85, blue: 0.83))
                .frame(width: size, height: size)

            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.48, height: size * 0.48)
                .foregroundColor(Color(red: 0.60, green: 0.58, blue: 0.56))
        }
    }
}

#Preview {
    LeaderboardView()
}
