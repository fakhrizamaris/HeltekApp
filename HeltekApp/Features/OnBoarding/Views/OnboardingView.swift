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
                            // DEBUG: Cetak ke console setiap tombol ditekan
                            print("🔘 Tombol ditekan! currentPage = \(currentPage), total pages = \(pages.count)")
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
                        
                        // DEBUG: Tampilkan status langsung di layar
                        // Hapus VStack ini setelah berhasil!
                        VStack(spacing: 4) {
                            Text("DEBUG INFO")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.red)
                            Text("currentPage: \(currentPage) / \(pages.count - 1)")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                            Text("hasSeenOnboarding: \(hasSeenOnboarding ? "TRUE ✅" : "FALSE ❌")")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                            Text("isLastPage: \(currentPage == pages.count - 1 ? "YA ✅" : "BELUM ❌")")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                        }
                        .padding(8)
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 44)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Tombol Skip (halaman 2 & 3, bukan splash & bukan terakhir)
            if currentPage > 0 && currentPage < pages.count - 1 {
                Button(action: {
                    print("⏭️ Skip ditekan! Set hasSeenOnboarding = true")
                    hasSeenOnboarding = true
                    print("⏭️ Setelah set, hasSeenOnboarding = \(hasSeenOnboarding)")
                }) {
                    Text("Skip")
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(Color.themePrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                }
                .padding(.top, 6)
                .padding(.trailing, 16)
            }
        }
        // Auto-advance splash screen setelah 2 detik
        .onAppear {
            print("👋 OnboardingView muncul. hasSeenOnboarding = \(hasSeenOnboarding)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if currentPage == 0 {
                    print("⏩ Auto-advance dari splash ke halaman 1")
                    withAnimation(.easeInOut) {
                        currentPage = 1
                    }
                }
            }
        }
        // DEBUG: Pantau setiap perubahan hasSeenOnboarding
        .onChange(of: hasSeenOnboarding) { oldValue, newValue in
            print("🔄 hasSeenOnboarding berubah: \(oldValue) → \(newValue)")
            print("🔄 Seharusnya sekarang pindah ke LoginView!")
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
            print("➡️ Pindah ke halaman \(currentPage + 1)")
            withAnimation { currentPage += 1 }
        } else {
            // Halaman terakhir — selesai onboarding
            print("🏁 Halaman terakhir! Set hasSeenOnboarding = true")
            hasSeenOnboarding = true
            print("🏁 Nilai hasSeenOnboarding sekarang = \(hasSeenOnboarding)")
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

