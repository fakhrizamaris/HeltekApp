//
//  ReminderView.swift
//  HeltekApp
//
//  Created by Brian Anashari on 11/03/26.
//


import SwiftUI

struct ReminderView: View {
    // Menyiapkan fungsi untuk menutup halaman (dismiss)
    @Environment(\.dismiss) var dismiss
    
    // Definisi Warna Kustom (Menyesuaikan palet sebelumnya)
    let bgColor = Color(red: 0.98, green: 0.98, blue: 0.99)
    let darkText = Color(red: 0.08, green: 0.12, blue: 0.18)
    let grayText = Color(red: 0.45, green: 0.48, blue: 0.55)
    let primaryOrange = Color(red: 0.93, green: 0.44, blue: 0.24)
    let secondaryBtnBg = Color(red: 0.96, green: 0.89, blue: 0.86)
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (Tombol Close & Judul)
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(darkText)
                }
                
                Spacer()
                
                Text("REMINDER")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(darkText)
                    .tracking(1.5)
                
                Spacer()
                
                // Placeholder kosong untuk menyeimbangkan layout HStack
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold))
                .opacity(0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 30)
            
            // 2. Gambar Utama dengan Badge
            // Ganti "exercise_image" dengan nama gambar Anda di Assets
            Image("reminder") // <-- Pastikan memasukkan gambar ke Assets.xcassets
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 380)
                .background(Color(red: 0.90, green: 0.90, blue: 0.90)) // Warna sementara jika gambar belum ada
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    // Badge "60 SECONDS"
                    VStack {
                        HStack {
                            Spacer()
                            Text("60 SECONDS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(primaryOrange)
                                .tracking(1.0)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        .padding(16)
                        Spacer()
                    }
                )
                .padding(.horizontal, 24)
                // Bayangan lembut di bawah gambar (opsional)
                .shadow(color: primaryOrange.opacity(0.1), radius: 20, x: 0, y: 15)
            
            Spacer()
                .frame(height: 32)
            
            // 3. Teks Judul (Time to Move!)
            HStack(spacing: 8) {
                Text("Time to")
                    .foregroundColor(darkText)
                Text("Move!")
                    .foregroundColor(primaryOrange)
            }
            .font(.system(size: 34, weight: .heavy, design: .rounded))
            
            Spacer()
                .frame(height: 16)
            
            // 4. Teks Deskripsi
            Text("Your body needs a 60-second\nbreak. Ready to refresh your\nenergy and stretch?")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(grayText)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
            
            Spacer()
            
            
            // 5. Action Buttons
            VStack(spacing: 16) {
                // Primary Button
                Button(action: {
                    // Aksi untuk Start Exercise
                }) {
                    Text("Start Exercise")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(primaryOrange)
                        .cornerRadius(16)
                        .shadow(color: primaryOrange.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                // Secondary Button
                Button(action: {
                    dismiss() // Biasanya "Maybe later" akan menutup halaman juga
                }) {
                    Text("Maybe later")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(darkText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(secondaryBtnBg)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(bgColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Previews
struct ReminderView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderView()
    }
}
