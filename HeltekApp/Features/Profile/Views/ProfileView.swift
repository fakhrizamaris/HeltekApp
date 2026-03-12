//
//  ProfileView.swift
//  HeltekApp
//
//  Created by Brian Anashari on 11/03/26.
//


import SwiftUI

struct ProfileView: View {
    // Definisi Warna Kustom
    let bgColor = Color(red: 0.96, green: 0.96, blue: 0.97)
    let darkText = Color(red: 0.08, green: 0.12, blue: 0.18)
    let grayText = Color(red: 0.58, green: 0.62, blue: 0.68)
    let orangeIcon = Color(red: 0.93, green: 0.44, blue: 0.24)
    let lightOrangeBg = Color(red: 0.98, green: 0.91, blue: 0.89)
    let logoutRed = Color(red: 0.88, green: 0.35, blue: 0.35)
    let logoutRedBg = Color(red: 0.98, green: 0.93, blue: 0.93)
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Navigation Header
            HStack {

                
                Text("Profile")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(darkText)
                
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // 2. Profile Info (Avatar, Name, Email)
                    VStack(spacing: 12) {
                        // Ganti "person.crop.circle.fill" dengan nama gambar aset Anda (misal: Image("baby_avatar"))
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85)) // Hapus baris ini jika pakai gambar asli
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color(red: 0.90, green: 0.90, blue: 0.92), lineWidth: 4)
                            )
                        
                        VStack(spacing: 4) {
                            Text("Eeyoo BRO")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(darkText)
                            
                            Text(verbatim: "eeyoo@magerin.app")
                                .font(.subheadline)
                                .foregroundColor(grayText)
                        }
                    }
                    
                    // 3. Preferences Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PREFERENCES")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(darkText)
                            .tracking(1.5)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 0) {
                            PreferenceRowView(
                                icon: "person",
                                title: "Account Settings"
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            PreferenceRowView(
                                icon: "bell",
                                title: "Notification Preferences",
                                subtitle: "Manage reminders & alerts"
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            PreferenceRowView(
                                icon: "questionmark.circle",
                                title: "Help & Support"
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    
                    // 4. Logout Button
                    Button(action: {
                        // Aksi Logout
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Logout")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(logoutRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(logoutRedBg)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(logoutRed.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(bgColor.ignoresSafeArea())
    }
}

// MARK: - Subviews

struct PreferenceRowView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    
    let darkText = Color(red: 0.08, green: 0.12, blue: 0.18)
    let grayText = Color(red: 0.58, green: 0.62, blue: 0.68)
    let orangeIcon = Color(red: 0.93, green: 0.44, blue: 0.24)
    let lightOrangeBg = Color(red: 0.98, green: 0.91, blue: 0.89)
    
    var body: some View {
        Button(action: {
            // Aksi ketika row ditekan
        }) {
            HStack(spacing: 16) {
                // Icon Background
                Circle()
                    .fill(lightOrangeBg)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(orangeIcon)
                            .font(.system(size: 16, weight: .semibold))
                    )
                
                // Text Container
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(darkText)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(grayText)
                    }
                }
                
                Spacer()
                
                // Chevron Icon
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.80))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            // Latar belakang transparan agar area button bisa di-tap semua
            .contentShape(Rectangle()) 
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
