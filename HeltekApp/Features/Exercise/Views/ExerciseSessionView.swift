//
//  ExerciseSessionView.swift
//  HeltekApp
//
//  Created by Brian Anashari on 11/03/26.
//


import SwiftUI

struct ExerciseSessionView: View {
    @Environment(\.dismiss) var dismiss
    
    // Definisi Warna Kustom
    let bgColor = Color(red: 0.98, green: 0.98, blue: 0.99)
    let darkText = Color(red: 0.08, green: 0.12, blue: 0.18)
    let grayText = Color(red: 0.58, green: 0.62, blue: 0.68)
    let primaryOrange = Color(red: 0.93, green: 0.44, blue: 0.24)
    let lightOrangeBg = Color(red: 0.98, green: 0.91, blue: 0.89)
    let pauseBgColor = Color(red: 0.89, green: 0.92, blue: 0.95)
    let doneCardBg = Color(red: 0.92, green: 0.95, blue: 0.92)
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(darkText)
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.04))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Morning Mobility")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(darkText)
                
                Spacer()
                
                // Placeholder untuk menyeimbangkan layout
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            // Area yang bisa di-scroll
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // 2. Main Timer (Circular)
                    ZStack {
                        // Lingkaran Oranye (Bisa dimodifikasi pakai .trim jika ingin animasinya berjalan)
                        Circle()
                            .stroke(primaryOrange, lineWidth: 8)
                            .frame(width: 180, height: 180)
                        
                        VStack(spacing: 4) {
                            Text("00:45")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundColor(darkText)
                            
                            Text("REMAINING")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(grayText)
                                .tracking(1.5)
                        }
                    }
                    .padding(.top, 10)
                    
                    // 3. Active Exercise Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Active Exercise")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(darkText)
                            
                            Spacer()
                            
                            Text("STEP 2/4")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(primaryOrange)
                                .tracking(1.0)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(lightOrangeBg)
                                .clipShape(Capsule())
                        }
                        
                        // Active Card
                        HStack(spacing: 16) {
                            // Placeholder gambar, ganti dengan aset asli Anda
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(.gray)
                                )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Neck Rotations")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(darkText)
                                
                                HStack {
                                    Text("08s left")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(primaryOrange)
                                    Spacer()
                                }
                                
                                // Progress Bar Mini
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(height: 6)
                                    Capsule()
                                        .fill(primaryOrange)
                                        .frame(width: 60, height: 6) // Progress dummy
                                }
                            }
                            
                            Spacer()
                            
                            // Skip Button
                            Button(action: {}) {
                                Circle()
                                    .fill(primaryOrange)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "forward.end.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    )
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(primaryOrange, lineWidth: 2) // Border oranye
                        )
                    }
                    
                    // 4. Up Next Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Up Next")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(darkText)
                        
                        VStack(spacing: 12) {
                            // Item 1: Done State
                            ExerciseDoneRowView()
                            
                            // Item 2: Upcoming
                            ExerciseUpcomingRowView(title: "Side Stretches", duration: "15 SECONDS")
                            
                            // Item 3: Upcoming
                            ExerciseUpcomingRowView(title: "Arm Circles", duration: "15 SECONDS")
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            
            // 5. Bottom Action Area (Sticky)
            VStack {
                Divider()
                HStack(spacing: 16) {
                    // Pause Button
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "pause")
                                .font(.headline)
                            Text("Pause")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(darkText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(pauseBgColor)
                        .cornerRadius(16)
                    }
                    
                    // End Session Button
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.headline)
                            Text("End Session")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(primaryOrange)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .background(bgColor)
        }
        .background(bgColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Subviews

struct ExerciseDoneRowView: View {
    let grayText = Color(red: 0.58, green: 0.62, blue: 0.68)
    let doneCardBg = Color(red: 0.94, green: 0.96, blue: 0.94) // Sedikit kehijauan
    
    var body: some View {
        HStack(spacing: 16) {
            // Gambar Done
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.gray.opacity(0.5))
                )
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.gray))
                        .offset(x: 18, y: 18) // Posisi checkmark di pojok kanan bawah gambar
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Shoulder Rolls")
                    .font(.headline)
                    .fontWeight(.bold)
                    .strikethrough() // Garis coret
                    .foregroundColor(grayText)
                
                Text("15s • Done")
                    .font(.caption)
                    .foregroundColor(grayText)
            }
            Spacer()
        }
        .padding(16)
        .background(doneCardBg)
        .cornerRadius(16)
    }
}

struct ExerciseUpcomingRowView: View {
    let title: String
    let duration: String
    
    let darkText = Color(red: 0.08, green: 0.12, blue: 0.18)
    let grayText = Color(red: 0.58, green: 0.62, blue: 0.68)
    
    var body: some View {
        HStack(spacing: 16) {
            // Gambar Upcoming
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "figure.arms.open")
                        .foregroundColor(darkText)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(darkText)
                
                Text(duration)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(grayText)
            }
            
            Spacer()
            
            // Drag Handle Icon (=)
            Image(systemName: "line.3.horizontal")
                .foregroundColor(grayText.opacity(0.6))
                .font(.system(size: 20))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Previews
struct ExerciseSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSessionView()
    }
}