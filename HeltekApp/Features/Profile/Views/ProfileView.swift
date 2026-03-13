//
//  ProfileView.swift
//  HeltekApp
//
//  Created by Brian Anashari on 11/03/26.
//  Updated: Menampilkan data user dari AppStorage + tombol Logout
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var authVM = AuthViewModel()
    
    // Data user dari AppStorage — sama dengan yang di-set di ProfileSetup
    @AppStorage("userName")  private var userName = "User"
    @AppStorage("userEmail") private var userEmail = ""
    @AppStorage("userID")    private var userID = ""
    
    @Environment(\.dismiss) private var dismiss
    
    // State untuk konfirmasi logout
    @State private var showLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // MARK: - Profile Info (Avatar, Name, Email)
                    VStack(spacing: 12) {
                        // Avatar dengan inisial
                        ZStack {
                            Circle()
                                .fill(Color.themePrimaryFaded)
                                .frame(width: 100, height: 100)
                            
                            Text(initials)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.themePrimary)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.themePrimary.opacity(0.2), lineWidth: 3)
                        )
                        
                        VStack(spacing: 4) {
                            Text(userName.isEmpty ? "User" : userName)
                                .font(ThemeFont.title)
                                .foregroundColor(.textPrimary)
                            
                            Text(userEmail)
                                .font(ThemeFont.body)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Preferences Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PREFERENCES")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .tracking(1.5)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 0) {
                            ProfileRowView(
                                icon: "person.fill",
                                title: "Edit Profil",
                                subtitle: "Ubah nama, umur, pekerjaan"
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            ProfileRowView(
                                icon: "bell.fill",
                                title: "Pengingat Stretching",
                                subtitle: "Atur notifikasi setiap 45 menit"
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            ProfileRowView(
                                icon: "questionmark.circle.fill",
                                title: "Bantuan & Dukungan"
                            )
                        }
                        .background(Color.themeSurface)
                        .cornerRadius(ThemeStyle.cornerRadius)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    }
                    
                    // MARK: - App Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("TENTANG")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .tracking(1.5)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 0) {
                            ProfileRowView(
                                icon: "info.circle.fill",
                                title: "Tentang Heltek",
                                subtitle: "Versi 1.0.0"
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            ProfileRowView(
                                icon: "doc.text.fill",
                                title: "Kebijakan Privasi"
                            )
                        }
                        .background(Color.themeSurface)
                        .cornerRadius(ThemeStyle.cornerRadius)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    }
                    
                    // MARK: - Logout Button
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Logout")
                                .font(ThemeFont.button)
                        }
                        .foregroundColor(.alertDestructive)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.alertBackground)
                        .cornerRadius(ThemeStyle.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                                .stroke(Color.alertDestructive.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Batal", role: .cancel) {}
            Button("Logout", role: .destructive) {
                authVM.logout()
            }
        } message: {
            Text("Apakah kamu yakin ingin keluar dari akun?")
        }
    }
    
    // MARK: - Inisial dari nama user
    private var initials: String {
        let parts = userName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? "U"
        let last = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }
}

// MARK: - Profile Row View (Reusable)
struct ProfileRowView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        Button(action: {
            // Aksi ketika row ditekan
        }) {
            HStack(spacing: 16) {
                // Icon Background
                Circle()
                    .fill(Color.themePrimaryFaded)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(.themePrimary)
                            .font(.system(size: 16, weight: .semibold))
                    )
                
                // Text Container
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(ThemeFont.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                // Chevron Icon
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textSecondary.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileView()
    }
}
