//
//  UserProfileSetupView.swift
//  HeltekApp
//
//  View untuk mengisi data diri user setelah login/registrasi.
//  Form step-by-step agar user tidak kewalahan.
//  Target: Orang dengan Sedentary Lifestyle.
//

import SwiftUI

struct UserProfileSetupView: View {
    
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.themeBackground,
                    Color.themePrimary.opacity(0.05),
                    Color.themeBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                headerSection
                
                // MARK: - Progress Bar
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // MARK: - Content
                TabView(selection: $viewModel.currentStep) {
                    stepNameView.tag(0)
                    stepAgeView.tag(1)
                    stepOccupationView.tag(2)
                    stepSittingView.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentStep)
                
                // MARK: - Bottom Buttons
                bottomButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateContent = true
            }
        }
        .alert("Oops!", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            // Icon sesuai step
            ZStack {
                Circle()
                    .fill(Color.themePrimaryFaded)
                    .frame(width: 80, height: 80)
                
                Image(systemName: stepIcon)
                    .font(.system(size: 36))
                    .foregroundColor(.themePrimary)
                    .symbolEffect(.bounce, value: viewModel.currentStep)
            }
            .padding(.top, 20)
            
            Text(stepTitle)
                .font(ThemeFont.title)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(stepSubtitle)
                .font(ThemeFont.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // MARK: - Step Icon, Title, Subtitle
    private var stepIcon: String {
        switch viewModel.currentStep {
        case 0: return "person.fill"
        case 1: return "calendar.badge.clock"
        case 2: return "briefcase.fill"
        case 3: return "chair.fill"
        default: return "person.fill"
        }
    }
    
    private var stepTitle: String {
        switch viewModel.currentStep {
        case 0: return "Siapa Nama Kamu?"
        case 1: return "Berapa Umur Kamu?"
        case 2: return "Apa Pekerjaanmu?"
        case 3: return "Berapa Lama Duduk?"
        default: return ""
        }
    }
    
    private var stepSubtitle: String {
        switch viewModel.currentStep {
        case 0: return "Biar kita bisa menyapamu dengan hangat 👋"
        case 1: return "Kami akan menyesuaikan program stretching untukmu"
        case 2: return "Kami ingin tahu jenis pekerjaan yang sering duduk"
        case 3: return "Ini membantu kami mengatur pengingat stretching untukmu"
        default: return ""
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<viewModel.totalSteps, id: \.self) { step in
                    Capsule()
                        .fill(step <= viewModel.currentStep
                              ? Color.themePrimary
                              : Color.themePrimary.opacity(0.15))
                        .frame(height: 4)
                        .animation(.spring(response: 0.3), value: viewModel.currentStep)
                }
            }
            
            Text("Langkah \(viewModel.currentStep + 1) dari \(viewModel.totalSteps)")
                .font(ThemeFont.caption)
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Step 1: Nama
    private var stepNameView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 16) {
                // Nama Lengkap
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nama Lengkap")
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.themePrimary)
                            .frame(width: 20)
                        
                        TextField("Masukkan nama lengkapmu", text: $viewModel.fullName)
                            .font(ThemeFont.body)
                            .autocorrectionDisabled()
                    }
                    .padding(16)
                    .background(Color.themeSurface)
                    .cornerRadius(ThemeStyle.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                            .stroke(
                                viewModel.fullName.isEmpty
                                    ? Color.clear
                                    : Color.themePrimary.opacity(0.3),
                                lineWidth: 1.5
                            )
                    )
                }
                
                // Bio / Data Diri
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tentang Kamu (opsional)")
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(.textPrimary)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "text.quote")
                            .foregroundColor(.themePrimary)
                            .frame(width: 20)
                            .padding(.top, 4)
                        
                        TextField("Ceritakan sedikit tentang dirimu...", text: $viewModel.bio, axis: .vertical)
                            .font(ThemeFont.body)
                            .lineLimit(3...5)
                    }
                    .padding(16)
                    .background(Color.themeSurface)
                    .cornerRadius(ThemeStyle.cornerRadius)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Step 2: Umur
    private var stepAgeView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Umur")
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "number")
                            .foregroundColor(.themePrimary)
                            .frame(width: 20)
                        
                        TextField("Contoh: 25", text: $viewModel.age)
                            .font(ThemeFont.body)
                            .keyboardType(.numberPad)
                    }
                    .padding(16)
                    .background(Color.themeSurface)
                    .cornerRadius(ThemeStyle.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                            .stroke(
                                viewModel.age.isEmpty
                                    ? Color.clear
                                    : (Int(viewModel.age) != nil
                                       ? Color.themePrimary.opacity(0.3)
                                       : Color.alertDestructive.opacity(0.5)),
                                lineWidth: 1.5
                            )
                    )
                    
                    if let ageInt = Int(viewModel.age), (ageInt < 10 || ageInt > 100) {
                        Text("Umur harus antara 10 - 100 tahun")
                            .font(ThemeFont.caption)
                            .foregroundColor(.alertDestructive)
                    }
                }
                
                // Fun fact card
                funFactCard(
                    icon: "💡",
                    title: "Tahukah kamu?",
                    text: "Duduk terlalu lama bisa meningkatkan risiko penyakit jantung. Stretching 30 detik setiap 45 menit bisa membantu!"
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Step 3: Pekerjaan
    private var stepOccupationView: some View {
        VStack(spacing: 16) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(OccupationType.allCases, id: \.self) { occupation in
                        occupationRow(occupation)
                    }
                    
                    // Custom input jika pilih "Lainnya"
                    if viewModel.selectedOccupation == .other {
                        HStack(spacing: 12) {
                            Image(systemName: "pencil")
                                .foregroundColor(.themePrimary)
                                .frame(width: 20)
                            
                            TextField("Tulis pekerjaanmu...", text: $viewModel.customOccupation)
                                .font(ThemeFont.body)
                        }
                        .padding(16)
                        .background(Color.themeSurface)
                        .cornerRadius(ThemeStyle.cornerRadius)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Occupation Row
    private func occupationRow(_ occupation: OccupationType) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.selectedOccupation = occupation
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: occupationIcon(for: occupation))
                    .font(.system(size: 18))
                    .foregroundColor(
                        viewModel.selectedOccupation == occupation
                            ? .white
                            : .themePrimary
                    )
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(
                                viewModel.selectedOccupation == occupation
                                    ? Color.themePrimary
                                    : Color.themePrimaryFaded
                            )
                    )
                
                Text(occupation.rawValue)
                    .font(ThemeFont.body)
                    .foregroundColor(
                        viewModel.selectedOccupation == occupation
                            ? .themePrimary
                            : .textPrimary
                    )
                
                Spacer()
                
                if viewModel.selectedOccupation == occupation {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.themePrimary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                    .fill(
                        viewModel.selectedOccupation == occupation
                            ? Color.themePrimaryFaded
                            : Color.themeSurface
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                    .stroke(
                        viewModel.selectedOccupation == occupation
                            ? Color.themePrimary.opacity(0.4)
                            : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Occupation Icons
    private func occupationIcon(for type: OccupationType) -> String {
        switch type {
        case .programmer:   return "laptopcomputer"
        case .designer:     return "paintbrush.fill"
        case .dataEntry:    return "keyboard"
        case .writer:       return "doc.text.fill"
        case .accountant:   return "banknote"
        case .admin:        return "folder.fill"
        case .student:      return "graduationcap.fill"
        case .gamer:        return "gamecontroller.fill"
        case .callCenter:   return "headphones"
        case .researcher:   return "magnifyingglass"
        case .other:        return "ellipsis"
        }
    }
    
    // MARK: - Step 4: Durasi Duduk
    private var stepSittingView: some View {
        VStack(spacing: 16) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(SittingDuration.allCases, id: \.self) { duration in
                        sittingDurationRow(duration)
                    }
                    
                    // Risk Info Card
                    riskInfoCard
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Sitting Duration Row
    private func sittingDurationRow(_ duration: SittingDuration) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.selectedSittingDuration = duration
            }
        } label: {
            HStack(spacing: 14) {
                Text(duration.icon)
                    .font(.system(size: 24))
                    .frame(width: 36)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(duration.label)
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(
                            viewModel.selectedSittingDuration == duration
                                ? .themePrimary
                                : .textPrimary
                        )
                    
                    Text(duration.riskLevel)
                        .font(ThemeFont.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if viewModel.selectedSittingDuration == duration {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.themePrimary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                    .fill(
                        viewModel.selectedSittingDuration == duration
                            ? Color.themePrimaryFaded
                            : Color.themeSurface
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                    .stroke(
                        viewModel.selectedSittingDuration == duration
                            ? Color.themePrimary.opacity(0.4)
                            : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Risk Info Card
    private var riskInfoCard: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "heart.text.clipboard")
                    .foregroundColor(.themePrimary)
                Text("Rekomendasi Stretching")
                    .font(ThemeFont.bodyBold)
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            
            Text("Berdasarkan durasi dudukmu, kami akan mengingatkan kamu untuk **stretching selama 30 detik setiap 45 menit** saat kamu beraktivitas duduk.")
                .font(ThemeFont.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                .fill(Color.themePrimary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                .stroke(Color.themePrimary.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Fun Fact Card
    private func funFactCard(icon: String, title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(ThemeFont.bodyBold)
                    .foregroundColor(.textPrimary)
            }
            
            Text(text)
                .font(ThemeFont.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius)
                .fill(Color.themePrimary.opacity(0.06))
        )
    }
    
    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        HStack(spacing: 12) {
            // Back Button
            if viewModel.currentStep > 0 {
                Button {
                    viewModel.previousStep()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Kembali")
                    }
                    .font(ThemeFont.body)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.themeSurface)
                    )
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            Spacer()
            
            // Next / Selesai Button
            Button {
                if viewModel.currentStep == viewModel.totalSteps - 1 {
                    // Last step — simpan profil
                    Task {
                        await viewModel.saveProfile()
                    }
                } else {
                    viewModel.nextStep()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(viewModel.currentStep == viewModel.totalSteps - 1
                             ? "Selesai 🎉"
                             : "Lanjut")
                            .font(ThemeFont.button)
                        
                        if viewModel.currentStep < viewModel.totalSteps - 1 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            viewModel.isCurrentStepValid
                                ? Color.themePrimary
                                : Color.themePrimary.opacity(0.4)
                        )
                )
                .shadow(
                    color: viewModel.isCurrentStepValid
                        ? Color.themePrimary.opacity(0.3)
                        : Color.clear,
                    radius: 8, x: 0, y: 4
                )
            }
            .disabled(!viewModel.isCurrentStepValid || viewModel.isLoading)
        }
        .animation(.spring(response: 0.3), value: viewModel.currentStep)
    }
}

// MARK: - Preview
#Preview {
    UserProfileSetupView()
}
