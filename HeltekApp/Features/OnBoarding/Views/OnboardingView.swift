//
//  OnboardingView.swift
//  HeltekApp
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let isSystemImage: Bool
    let title: String
    let description: String
    var isSplash: Bool = false
    
    init(imageName: String, isSystemImage: Bool, title: String, description: String, isSplash: Bool = false) {
        self.imageName = imageName
        self.isSystemImage = isSystemImage
        self.title = title
        self.description = description
        self.isSplash = isSplash
    }
}

private let pages: [OnboardingPage] = [
    // Halaman 0: Splash — isSplash = true
    OnboardingPage(
        imageName: "Logo",    // ← nama logo kamu di Assets
        isSystemImage: false,
        title: "",
        description: "",
        isSplash: true           // ← tandai ini splash
    ),
    OnboardingPage(
        imageName: "OnBoard1",
        isSystemImage: false,
        title: "Stop Sitting,\nStart Moving",
        description: "Did you know that sitting too long is the new smoking? We help you stay active with quick, simple micro-exercises throughout your day."
    ),
    OnboardingPage(
        imageName: "OnBoard2",
        isSystemImage: false,
        title: "Grow Your Streak Pet",
        description: "Every exercise you complete helps your pet grow. Don't break the streak or your pet will be sad and reset!"
    ),
    OnboardingPage(
        imageName: "OnBoard3",
        isSystemImage: true,
        title: "Never Miss a Move",
        description: "Our smart reminders act like alarms. They won't stop until you take a quick 60-second break to stretch."
    )
]

struct OnboardingView: View {
    
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // MARK: - Bagian bawah
                // Sembunyikan SEMUA tombol kalau di halaman splash (index 0)
                if currentPage > 0 {
                    VStack(spacing: 20) {
                        
                        // Dots indikator
                        HStack(spacing: 6) {
                            ForEach(1..<pages.count, id: \.self) { index in
                                Capsule()
                                    .fill(currentPage == index
                                          ? Color.themePrimary
                                          : Color.gray.opacity(0.3))
                                    .frame(
                                        width: currentPage == index ? 24 : 8,
                                        height: 8
                                    )
                                    .animation(.spring(response: 0.3), value: currentPage)
                            }
                        }
                        
                        // Tombol Next / Get Started
                        Button(action: { handleNextTap() }) {
                            HStack(spacing: 8) {
                                Text(buttonLabel)
                                    .font(ThemeFont.button)
                                    .foregroundColor(.white)
                                
                                if currentPage < pages.count - 1 {
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.themePrimary)
                            .cornerRadius(ThemeStyle.cornerRadius)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 44)
                    // Animasi muncul dari bawah saat pindah dari splash
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Tombol Skip — muncul di halaman 2 dan 3 saja (bukan splash, bukan terakhir)
            if currentPage > 0 && currentPage < pages.count - 1 {
                Button(action: { hasSeenOnboarding = true }) {
                    Text("Skip")
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(Color.themePrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                }
                .padding(.top, 6)
                .padding(.trailing, 16)
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Hanya auto-advance kalau user masih di halaman splash
                // (belum swipe sendiri)
                if currentPage == 0 {
                    withAnimation(.easeInOut) {
                        currentPage = 1
                    }
                }
            }
        }
    }
    
    private var buttonLabel: String {
        currentPage == pages.count - 1 ? "Get Started" : "Next"
    }
    
    private func handleNextTap() {
        if currentPage < pages.count - 1 {
            withAnimation { currentPage += 1 }
        } else {
            // Ini yang bikin pindah ke LoginView
            // HeltekAppApp.swift akan deteksi perubahan ini otomatis
            hasSeenOnboarding = true
        }
    }
}

// Sub-view per halaman (tidak berubah)
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 0) {
            
            if page.isSplash {
                // MARK: - Splash Screen
                ZStack {
                    
                    // MARK: - Background: putih dengan 2 blob peach
                    Color.white.ignoresSafeArea()
                    
                    // Blob atas (kiri atas)
                    Circle()
                        .fill(Color(hex: "FFCBA4").opacity(0.5))
                        .frame(width: 280, height: 280)
                        .blur(radius: 60)          // blur = efek soft blob
                        .offset(x: 60, y: -320)  // geser ke kiri atas
                    
                    // Blob bawah (kanan bawah)
                    Circle()
                        .fill(Color(hex: "FFCBA4").opacity(0.5))
                        .frame(width: 280, height: 280)
                        .blur(radius: 60)
                        .offset(x: -60, y: 320)    // geser ke kanan bawah
                    
                    // MARK: - Konten tengah
                    VStack(spacing: 20) {
                        
                        // Logo card — white rounded square dengan shadow
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .frame(width: 110, height: 110)
                                .shadow(
                                    color: Color.black.opacity(0.12),
                                    radius: 20,
                                    x: 0,
                                    y: 8
                                )
                            
                            // Ganti "AppLogo" dengan nama asset logo kamu
                            Image(page.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                        }
                        
                        // MARK: - Typography "StepUP"
                        // "Step" gelap + "UP" orange dalam satu teks
                        // Pakai Text concatenation — seperti <span> di HTML
                        (
                            Text("Step")
                                .font(.custom("Lexend-Bold", size: 32))
                                .foregroundColor(Color.textPrimary)
                            +
                            Text("UP")
                                .font(.custom("Lexend-Bold", size: 32))
                                .foregroundColor(Color.themePrimary)
                        )
                        
                        // MARK: - Tagline
                        Text("SMALL STEP, BIG IMPACT")
                            .font(.custom("Lexend-Regular", size: 11))
                            .foregroundColor(Color.textSecondary)
                            .kerning(2.5)          // kerning = letter-spacing seperti di CSS
                            .tracking(2.5)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                
            } else {
                // MARK: - Tampilan normal halaman onboarding 2, 3, 4
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "FFF0E8"))
                        .frame(width: 280, height: 280)
                    
                    if page.isSystemImage {
                        Image(systemName: page.imageName)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.themePrimary)
                            .frame(width: 180, height: 180)
                    } else {
                        Image(page.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 240, height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.45)
                
                // Teks judul dan deskripsi
                if !page.title.isEmpty {
                    VStack(alignment: .center, spacing: 12) {
                        Text(page.title)
                            .font(ThemeFont.title)
                            .foregroundColor(Color.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(page.description)
                            .font(ThemeFont.body)
                            .foregroundColor(Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 28)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView()
}

