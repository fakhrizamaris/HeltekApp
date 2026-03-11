//
//  Theme.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import SwiftUI

// MARK: - 1. COLOR PALETTE
extension Color {
    // Background & Surface
    static let themeBackground = Color(hex: "F1F5F9")
    static let themeSurface = Color.white // Untuk card putih yang menonjol
    
    // Brand Colors
    static let themePrimary = Color(hex: "FF5E1F")
    static let themePrimaryFaded = Color(hex: "FF5E1F").opacity(0.1)
    
    // Text Colors
    static let textPrimary = Color(hex: "0F172A")
    static let textSecondary = Color(hex: "64748B")
    
    // Alert / Logout Colors
    static let alertDestructive = Color(hex: "EF4444")
    static let alertBackground = Color(hex: "FEE2E2")
}

// MARK: - 2. TYPOGRAPHY (Lexend)
struct ThemeFont {
    static let display = Font.custom("Lexend-Bold", size: 48) // Untuk Timer/Streak besar
    static let title = Font.custom("Lexend-Bold", size: 24)   // Untuk Judul Halaman
    static let button = Font.custom("Lexend-Bold", size: 18)  // Untuk Text di Tombol
    static let bodyBold = Font.custom("Lexend-Bold", size: 16) // Untuk Subtitle tebal
    static let body = Font.custom("Lexend-Regular", size: 16)  // Untuk teks instruksi
    static let caption = Font.custom("Lexend-Regular", size: 12) // Untuk label kecil
}

// MARK: - 3. SHAPES & SHADOWS
struct ThemeStyle {
    static let cornerRadius: CGFloat = 16
    
    static func cardShadow(for view: some View) -> some View {
        view.shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

// MARK: - HEX COLOR HELPER
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}
