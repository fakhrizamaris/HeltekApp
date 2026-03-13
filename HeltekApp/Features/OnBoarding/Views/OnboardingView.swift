//
//  OnboardingView.swift
//  HeltekApp
//

import SwiftUI

// MARK: - Enum gaya gambar per halaman
enum OnboardingImageStyle {
    case fullWidth
    case card
}

// MARK: - Model data tiap halaman
struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let isSystemImage: Bool
    let title: String
    let description: String
    var isSplash: Bool = false
    var imageStyle: OnboardingImageStyle = .card
}

// MARK: - Data konten 4 halaman
private let pages: [OnboardingPage] = [
    OnboardingPage(
        imageName: "Logo",
        isSystemImage: false,
        title: "",
        description: "",
        isSplash: true
    ),
    OnboardingPage(
        imageName: "OnBoard1",
        isSystemImage: false,
        title: "Stop Sitting,\nStart Moving",
        description: "Did you know that sitting too long is the new smoking? We help you stay active with quick, simple micro-exercises throughout your day.",
        imageStyle: .fullWidth
    ),
    OnboardingPage(
        imageName: "OnBoard2",
        isSystemImage: false,
        title: "Grow Your Streak Pet",
        description: "Every exercise you complete helps your pet grow. Don't break the streak or your pet will be sad and reset!",
        imageStyle: .card
    ),
    OnboardingPage(
        imageName: "OnBoard3",
        isSystemImage: false,
        title: "Never Miss a Move",
        description: "Our smart reminders act like alarms. They won't stop until you take a quick 60-second break to stretch.",
        imageStyle: .card
    )
]

// MARK: - Main View
struct OnboardingView: View {
    
    @State private var currentPage = 0
    
    // Saat nilai ini berubah jadi true,
    // HeltekAppApp.swift otomatis pindah ke LoginView
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // TabView swipeable
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Tombol dan dots — disembunyikan di halaman splash
                if currentPage > 0 {
                    VStack(spacing: 20) {
                        
                        // Dots indikator halaman
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
                        Button(action: {
                            handleNextTap()
                        }) {
                            HStack(spacing: 8) {
                                Text(buttonLabel)
                                    .font(ThemeFont.button)
                                    .foregroundColor(.white)
                                
                                // Panah hanya muncul di halaman non-terakhir
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Tombol Skip (halaman 2 & 3, bukan splash & bukan terakhir)
            if currentPage > 0 && currentPage < pages.count - 1 {
                Button(action: {
                    hasSeenOnboarding = true
                }) {
                    Text("Skip")
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(Color.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                }
                .padding(.top, 16)
                .padding(.trailing, 24)
            }
        }
        // Auto-advance splash screen setelah 2 detik
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if currentPage == 0 {
                    withAnimation(.easeInOut) {
                        currentPage = 1
                    }
                }
            }
        }
    }
    
    // Label tombol berubah di halaman terakhir
    private var buttonLabel: String {
        currentPage == pages.count - 1 ? "Get Started" : "Next"
    }
    
    // Logika tombol Next / Get Started
    private func handleNextTap() {
        if currentPage < pages.count - 1 {
            // Belum halaman terakhir — pindah ke halaman berikutnya
            withAnimation { currentPage += 1 }
        } else {
            // Halaman terakhir — selesai onboarding
            hasSeenOnboarding = true
        }
    }
}

// MARK: - Sub-view per halaman
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 0) {
            
            if page.isSplash {
                // MARK: - Splash Screen
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    // Blob peach kanan atas
                    Circle()
                        .fill(Color(hex: "FFCBA4").opacity(0.5))
                        .frame(width: 280, height: 280)
                        .blur(radius: 60)
                        .offset(x: 60, y: -320)
                    
                    // Blob peach kiri bawah
                    Circle()
                        .fill(Color(hex: "FFCBA4").opacity(0.5))
                        .frame(width: 280, height: 280)
                        .blur(radius: 60)
                        .offset(x: -60, y: 320)
                    
                    VStack(spacing: 16) {
                        // Logo card putih dengan shadow
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .frame(width: 110, height: 110)
                                .shadow(
                                    color: Color.black.opacity(0.12),
                                    radius: 20, x: 0, y: 8
                                )
                            
                            Image(page.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                        }
                        
                        // "Step" gelap + "UP" orange
                        (
                            Text("Step")
                                .font(.custom("Lexend-Bold", size: 32))
                                .foregroundColor(Color.textPrimary)
                            +
                            Text("UP")
                                .font(.custom("Lexend-Bold", size: 32))
                                .foregroundColor(Color.themePrimary)
                        )
                        
                        Text("SMALL STEP, BIG IMPACT")
                            .font(.custom("Lexend-Regular", size: 11))
                            .foregroundColor(Color.textSecondary)
                            .kerning(2.5)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                
            } else if page.imageStyle == .fullWidth {
                // MARK: - Layout Full Width (Onboarding 2)
                Image(page.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.main.bounds.height * 0.42)
                    .clipped()
                    .clipShape(
                        RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight])
                    )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(page.title)
                        .font(ThemeFont.title)
                        .foregroundColor(Color.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(page.description)
                        .font(ThemeFont.body)
                        .foregroundColor(Color.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                
                Spacer()
                
            } else {
                // MARK: - Layout Card (Onboarding 3 & 4)
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "FFF0E8"))
                        .padding(.horizontal, 24)
                    
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
                            .padding(20)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.42)
                
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
                .padding(.top, 24)
                
                Spacer()
            }
        }
    }
}

// MARK: - Helper untuk rounded corner hanya di sudut tertentu
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    OnboardingView()
}
