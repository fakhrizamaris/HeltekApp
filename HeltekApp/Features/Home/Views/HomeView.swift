import SwiftUI
import Combine
import TipKit

// MARK: - Spotlight Coach Marks System

/// Setiap step walkthrough membawa data: ID elemen, frame global, judul & deskripsi.
struct WalkthroughStep: Identifiable, Equatable {
    let id: Int
    let title: String
    let desc: String
    /// Apakah cutout-nya berbentuk lingkaran (Circle) atau rounded rect
    let isCircle: Bool
    /// Padding tambahan di luar frame elemen agar cutout lebih leluasa
    var padding: CGFloat = 16
}

/// PreferenceKey untuk mengumpulkan frame tiap elemen target dari seluruh view tree.
struct SpotlightFrameKey: PreferenceKey {
    typealias Value = [Int: CGRect]
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

/// Modifier untuk melapor frame ke PreferenceKey.
struct SpotlightFrameModifier: ViewModifier {
    let stepID: Int
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: SpotlightFrameKey.self,
                            value: [stepID: geo.frame(in: .global)]
                        )
                }
            )
    }
}

extension View {
    /// Tandai view ini sebagai target spotlight untuk step tertentu.
    func spotlightTarget(stepID: Int) -> some View {
        modifier(SpotlightFrameModifier(stepID: stepID))
    }
}

// MARK: - Spotlight Mask Shape

/// Shape yang menggambar rect penuh lalu "melubangi" area cutout dengan even-odd fill rule.
struct SpotlightMaskShape: Shape {
    var rect: CGRect
    var cornerRadius: CGFloat
    var padding: CGFloat

    /// Animatable data agar SwiftUI bisa interpolasi cutout saat berpindah step.
    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
        get {
            AnimatablePair(
                AnimatablePair(rect.origin.x, rect.origin.y),
                AnimatablePair(rect.size.width, rect.size.height)
            )
        }
        set {
            rect = CGRect(
                x: newValue.first.first,
                y: newValue.first.second,
                width: newValue.second.first,
                height: newValue.second.second
            )
        }
    }

    func path(in bounds: CGRect) -> Path {
        var path = Path()
        // Seluruh layar sebagai background gelap
        path.addRect(bounds)
        // Cutout — menggunakan padding agar sedikit lebih besar dari elemen
        let cutout = rect.insetBy(dx: -padding, dy: -padding)
        if cornerRadius >= cutout.height / 2 {
            // Bentuk lingkaran
            path.addEllipse(in: cutout)
        } else {
            path.addRoundedRect(in: cutout, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        }
        return path
    }
}

// MARK: - Spotlight Overlay View

struct SpotlightOverlayView: View {
    let steps: [WalkthroughStep]
    let currentStepID: Int
    let frames: [Int: CGRect]
    let onNext: () -> Void

    private var currentStep: WalkthroughStep? {
        steps.first { $0.id == currentStepID }
    }

    private var currentFrame: CGRect {
        guard let step = currentStep, let frame = frames[step.id] else {
            return .zero
        }
        return frame
    }

    private func tooltipAbove(screenHeight: CGFloat) -> Bool {
        // Tampilkan tooltip di bawah elemen jika elemen berada di top-half layar
        return currentFrame.midY > screenHeight / 2
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let isTooltipAbove = tooltipAbove(screenHeight: screenHeight)
            
            if let step = currentStep, currentFrame != .zero {
                ZStack {
                    // MARK: Dimmed Mask with Cutout
                    SpotlightMaskShape(
                        rect: currentFrame,
                        cornerRadius: step.isCircle ? currentFrame.height / 2 : 20,
                        padding: step.padding
                    )
                    .fill(Color.black.opacity(0.72), style: FillStyle(eoFill: true))
                    .ignoresSafeArea()
                    .animation(.spring(response: 0.45, dampingFraction: 0.78), value: currentFrame)
                    .onTapGesture {
                        onNext()
                    }

                    // MARK: Glowing Ring Around Cutout
                    let cutoutRect = currentFrame.insetBy(dx: -step.padding, dy: -step.padding)
                    if step.isCircle {
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 2)
                            .frame(width: cutoutRect.width, height: cutoutRect.height)
                            .position(x: cutoutRect.midX, y: cutoutRect.midY)
                            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: currentFrame)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.25), lineWidth: 2)
                            .frame(width: cutoutRect.width, height: cutoutRect.height)
                            .position(x: cutoutRect.midX, y: cutoutRect.midY)
                            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: currentFrame)
                    }

                    // MARK: Tooltip Card
                    tooltipCard(step: step, screenWidth: screenWidth, isTooltipAbove: isTooltipAbove)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: isTooltipAbove ? .bottom : .top)),
                            removal: .opacity
                        ))
                        .id(step.id) // force re-render & transition on step change
                }
            }
        }
    }

    @ViewBuilder
    private func tooltipCard(step: WalkthroughStep, screenWidth: CGFloat, isTooltipAbove: Bool) -> some View {
        let cutoutRect = currentFrame.insetBy(dx: -step.padding, dy: -step.padding)
        let tooltipGap: CGFloat = 20
        let tooltipMaxWidth: CGFloat = screenWidth - 48
        let cardY: CGFloat = isTooltipAbove
            ? cutoutRect.minY - tooltipGap - 90   // atas elemen
            : cutoutRect.maxY + tooltipGap + 60   // bawah elemen

        VStack(spacing: 12) {
            // Arrow indicator pointing toward elemen
            Image(systemName: isTooltipAbove ? "chevron.down" : "chevron.up")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(.sRGB, red: 242/255, green: 110/255, blue: 60/255))

            Text(step.title)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(step.desc)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)

            Divider().background(Color.white.opacity(0.2))

            // Step counter + CTA
            HStack {
                Text("\(step.id) / 4")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Button(action: onNext) {
                    HStack(spacing: 4) {
                        Text(step.id < 4 ? "Next" : "Got it!")
                            .font(.caption)
                            .fontWeight(.semibold)
                        if step.id < 4 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color(.sRGB, red: 242/255, green: 110/255, blue: 60/255))
                    )
                }
            }
        }
        .padding(18)
        .frame(maxWidth: tooltipMaxWidth)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 8)
        .position(x: screenWidth / 2, y: cardY)
        .animation(.spring(response: 0.45, dampingFraction: 0.78), value: currentFrame)
    }
}

// MARK: - HomeView

struct HomeView: View {
    // MARK: - ViewModels & AppStorage
    @StateObject private var authVM = AuthViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("userName") private var userName = "User"
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough = false

    // MARK: - UI Colors
    let themeOrange = Color(.sRGB, red: 242/255, green: 110/255, blue: 60/255)
    let lightOrange = Color(.sRGB, red: 255/255, green: 245/255, blue: 240/255)

    // MARK: - Timer States
    @State private var timeRemaining = 1800
    @State private var isActive = false
    @State private var streakCount: Int = 0
    @State private var isCountdownPaused = false
    @State private var timerEndDate: Date?
    
    // MARK: - Timer States
    let timer = Timer.publish(every: 1, on: RunLoop.main, in: .common).autoconnect()

    // MARK: - Navigation & Sheet States
    @State private var showProfile = false
    @State private var showingBottomSheet = false
    @State private var selectedMinutes = 30
    @State private var navigateToSuccess = false
    @State private var navigateToSession = false
    @State private var didCompleteSession = false

    // MARK: - Walkthrough States
    /// 0 = tidak aktif, 1–4 = step aktif
    @State private var currentWalkthroughStep = 0
    /// Menyimpan frame global tiap elemen target
    @State private var spotlightFrames: [Int: CGRect] = [:]

    /// Definisi semua step walkthrough
    private let walkthroughSteps: [WalkthroughStep] = [
        WalkthroughStep(id: 1, title: "Your Profile",    desc: "Tap here to view and edit your profile settings.",                        isCircle: false, padding: 12),
        WalkthroughStep(id: 2, title: "Adjust Timer",    desc: "Tap the circle to set how often you want to be reminded to move.",        isCircle: true,  padding: 20),
        WalkthroughStep(id: 3, title: "Hatch & Evolve!", desc: "Keep your streak alive to hatch the egg and watch your pet evolve.",      isCircle: false, padding: 14),
        WalkthroughStep(id: 4, title: "Ready to Focus?", desc: "Tap here to start the timer and begin your focus session.",               isCircle: false, padding: 10),
    ]

    // MARK: - Pet Evolution Logic
    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
    }

    private var milestones: [Int] {
        [daysInMonth / 3, (daysInMonth * 2) / 3]
    }

    private var currentPetImage: String {
        if streakCount >= milestones[1] { return "pet_third_evo" }
        if streakCount >= milestones[0] { return "pet_second_evo" }
        return "pet_first_evo"
    }

    private var petStatusMessage: String {
        if streakCount >= milestones[1] { return "Your pet has fully evolved! You're unstoppable." }
        if streakCount >= milestones[0] { return "Your pet is growing! Keep the streak alive." }
        return "Your pet is hatching! Keep moving."
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Main Content
                VStack(spacing: 0) {
                    // MARK: Header
                    HStack {
                        Button {
                            showProfile = true
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(lightOrange)
                                    .frame(width: 45, height: 45)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(themeOrange)
                                    )

                                VStack(alignment: .leading) {
                                    Text(greeting)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(userName.isEmpty ? "User" : userName)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(.plain)
                        // ← Spotlight target step 1
                        .spotlightTarget(stepID: 1)

                        Spacer()

                        Button {
                                withAnimation {
                                    // Memanggil kembali walkthrough dari step pertama
                                    currentWalkthroughStep = 1
                                }
                            } label: {
                                Image(systemName: "info.circle")
                                    .font(.title3)
                                    .foregroundColor(themeOrange) // Menambahkan warna agar senada
                                    .padding(10)
                                    .background(Circle().fill(Color.white).shadow(radius: 1))
                            }
                            .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // MARK: Content Section
                    VStack(spacing: 30) {
                        HStack {
                            Text("Next Movement")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 40)

                        // Timer Circle Button — spotlight target step 2
                        Button(action: {
                            showingBottomSheet = true
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(lightOrange, lineWidth: 15)
                                    .frame(width: 250, height: 250)

                                Circle()
                                    .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(selectedMinutes > 0 ? selectedMinutes * 60 : 1800))
                                    .stroke(themeOrange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                    .frame(width: 260, height: 260)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut, value: timeRemaining)

                                Text(timeString(from: timeRemaining))
                                    .font(.system(size: 70, weight: .bold, design: .rounded))
                                    .foregroundColor(themeOrange)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        // ← Spotlight target step 2
                        .spotlightTarget(stepID: 2)

                        Text("Time to stand up and stretch those legs!")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(white: 0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                    }

                    // MARK: Streak Card — spotlight target step 3
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 15) {
                            ZStack {
                                Image(currentPetImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(themeOrange)
                                    .animation(.spring(), value: currentPetImage)
                                    
                            }

                            VStack(alignment: .leading) {
                                Text("CURRENT STREAK")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)

                                GeometryReader { geo in
                                    let circleSize: CGFloat = 16
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color(.systemGray6))
                                            .frame(height: 8)

                                        Capsule()
                                            .fill(themeOrange)
                                            .frame(width: min(geo.size.width, geo.size.width * CGFloat(streakCount) / CGFloat(daysInMonth)), height: 8)

                                        ForEach(milestones, id: \.self) { milestone in
                                            VStack(spacing: 2) {
                                                Circle()
                                                    .fill(streakCount >= milestone ? themeOrange : Color(.systemGray5))
                                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                    .frame(width: circleSize, height: circleSize)

                                                Text("\(milestone)")
                                                    .font(.system(size: 8, weight: .bold))
                                                    .foregroundColor(streakCount >= milestone ? themeOrange : .gray)
                                            }
                                            .offset(
                                                x: (geo.size.width * CGFloat(milestone) / CGFloat(daysInMonth)) - (circleSize / 2),
                                                y: 6
                                            )
                                        }
                                    }
                                    .frame(height: circleSize)
                                }
                                .frame(height: 16)
                            }

                            VStack(alignment: .trailing) {
                                Text("\(streakCount) Days")
                                    .font(.title3)
                                    .fontWeight(.black)
                            }
                        }

                        Text(petStatusMessage)
                            .font(.caption)
                            .foregroundColor(themeOrange)
                            .fontWeight(.medium)
                            .animation(.easeInOut, value: petStatusMessage)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 24)
                    // ← Spotlight target step 3
                    .spotlightTarget(stepID: 3)

                    // MARK: Start Button — spotlight target step 4
                    Button(action: {
                        if isActive {
                            isActive = false
                            isCountdownPaused = false
                            timeRemaining = selectedMinutes * 60
                            timerEndDate = nil
                            NotificationManager.shared.cancelTimerNotification()
                            LiveActivityManager.shared.end()
                            syncWidgetState(forceReload: true)
                        } else {
                            isActive = true
                            isCountdownPaused = false
                            timerEndDate = Date().addingTimeInterval(TimeInterval(timeRemaining))
                            NotificationManager.shared.scheduleTimerNotification(seconds: timeRemaining)
                            let endDate = Date().addingTimeInterval(TimeInterval(timeRemaining))
                            LiveActivityManager.shared.start(remainingSeconds: timeRemaining, endDate: endDate, title: "Next Movement")
                            syncWidgetState(forceReload: true)
                        }
                    }) {
                        HStack {
                            Image(systemName: isActive ? "stop.fill" : "bolt.fill")
                            Text(isActive ? "Stop" : "Start Focus")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isActive ? themeOrange.opacity(0.75) : themeOrange)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 30)
                    // ← Spotlight target step 4
                    .spotlightTarget(stepID: 4)

                } // VStack utama
                .background(Color(white: 0.98).ignoresSafeArea())

                // MARK: - Spotlight Overlay
                if currentWalkthroughStep > 0 {
                    SpotlightOverlayView(
                        steps: walkthroughSteps,
                        currentStepID: currentWalkthroughStep,
                        frames: spotlightFrames,
                        onNext: nextWalkthroughStep
                    )
                    .ignoresSafeArea()
                    .zIndex(10)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.25), value: currentWalkthroughStep)
                }

            } // ZStack
            // Kumpulkan semua frame dari PreferenceKey
            .onPreferenceChange(SpotlightFrameKey.self) { frames in
                spotlightFrames = frames
            }
            .task {
                NotificationManager.shared.requestAuthorization()
                await loadStreakCount()
                applySharedWidgetStateIfNeeded()
                syncWidgetState(forceReload: true)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if !hasSeenWalkthrough {
                        withAnimation { currentWalkthroughStep = 1 }
                    }
                }
            }
            .sheet(isPresented: $showingBottomSheet) {
                ReminderSheetView(
                    isPresented: $showingBottomSheet,
                    selectedMinutes: $selectedMinutes,
                    timeRemaining: $timeRemaining
                )
                .presentationDetents([.fraction(0.55), .medium])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView()
            }
            .navigationDestination(isPresented: $navigateToSuccess) {
                ReminderView(navigateToSession: $navigateToSession)
                    .onDisappear {
                        DispatchQueue.main.async {
                            if isActive && !navigateToSession {
                                resetTimerAndResume()
                            }
                        }
                    }
            }
            .navigationDestination(isPresented: $navigateToSession) {
                ExerciseSessionView(didCompleteSession: $didCompleteSession)
            }
            .onReceive(timer) { _ in
                applySharedWidgetStateIfNeeded()
                guard isActive, !isCountdownPaused else { return }
                if let endDate = timerEndDate {
                    timeRemaining = max(0, Int(endDate.timeIntervalSinceNow.rounded(.down)))
                } else {
                    timerEndDate = Date().addingTimeInterval(TimeInterval(timeRemaining))
                }
                syncWidgetState()
                if timeRemaining <= 0 {
                    isCountdownPaused = true
                    timerEndDate = nil
                    NotificationManager.shared.cancelTimerNotification()
                    NotificationManager.shared.playImportedSound(named: "pikachu", )
                    LiveActivityManager.shared.end()
                    syncWidgetState(forceReload: true)
                    navigateToSuccess = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .widgetStopTimerRequested)) { _ in
                guard isActive else { return }
                isActive = false
                isCountdownPaused = false
                timeRemaining = selectedMinutes * 60
                timerEndDate = nil
                NotificationManager.shared.cancelTimerNotification()
                LiveActivityManager.shared.end()
                syncWidgetState(forceReload: true)
            }
            .onChange(of: didCompleteSession) { _, newValue in
                guard newValue else { return }
                resetTimerAndResume()
            }
            .onChange(of: streakCount) { _, _ in
                syncWidgetState(forceReload: true)
            }
            .onChange(of: scenePhase) { _, newValue in
                guard newValue == .active else { return }
                applySharedWidgetStateIfNeeded()
            }
        } // NavigationStack
    }

    // MARK: - Walkthrough Navigation
    private func nextWalkthroughStep() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            if currentWalkthroughStep < 4 {
                currentWalkthroughStep += 1
            } else {
                currentWalkthroughStep = 0
                hasSeenWalkthrough = true
            }
        }
    }

    // MARK: - Helper Computed Properties
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning,"
        case 12..<17: return "Good Afternoon,"
        case 17..<19: return "Good Evening,"
        default:      return "Good Night,"
        }
    }

    func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @MainActor
    private func loadStreakCount() async {
        do {
            streakCount = try await FirebaseManager.shared.fetchCurrentUserStreakCount()
        } catch {
            print("❌ Failed to load streakCount: \(error.localizedDescription)")
        }
    }

    private func resetTimerAndResume() {
        timeRemaining = selectedMinutes * 60
        isCountdownPaused = false
        navigateToSuccess = false
        navigateToSession = false
        didCompleteSession = false
        if isActive {
            timerEndDate = Date().addingTimeInterval(TimeInterval(timeRemaining))
            NotificationManager.shared.scheduleTimerNotification(seconds: timeRemaining)
            let endDate = Date().addingTimeInterval(TimeInterval(timeRemaining))
            LiveActivityManager.shared.start(remainingSeconds: timeRemaining, endDate: endDate, title: "Next Movement")
        }
        syncWidgetState(forceReload: true)
    }

    private func syncWidgetState(forceReload: Bool = false) {
        WidgetSyncManager.shared.sync(
            remainingSeconds: timeRemaining,
            timerEndDate: timerEndDate,
            isActive: isActive,
            isPaused: isCountdownPaused,
            currentStreak: streakCount,
            forceReload: forceReload
        )
    }

    private func applySharedWidgetStateIfNeeded() {
        guard let defaults = UserDefaults(suiteName: WidgetSyncKeys.appGroupID) else { return }
        let isWidgetTimerActive = defaults.bool(forKey: WidgetSyncKeys.isTimerActive)
        let stopRequested = defaults.bool(forKey: WidgetSyncKeys.stopRequested)
        guard (!isWidgetTimerActive || stopRequested), isActive else { return }

        isActive = false
        isCountdownPaused = false
        timeRemaining = selectedMinutes * 60
        timerEndDate = nil
        NotificationManager.shared.cancelTimerNotification()
        LiveActivityManager.shared.end()
        defaults.set(false, forKey: WidgetSyncKeys.stopRequested)
        syncWidgetState(forceReload: true)
    }
}

// MARK: - Bottom Sheet View

struct ReminderSheetView: View {
    @Binding var isPresented: Bool
    @Binding var selectedMinutes: Int
    @Binding var timeRemaining: Int

    let themeOrange = Color(.sRGB, red: 242/255, green: 110/255, blue: 60/255)
    let lightOrange = Color(.sRGB, red: 255/255, green: 245/255, blue: 240/255)
    let intervalOptions = Array(stride(from: 1, through: 120, by: 1))

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Reminder Interval")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)

            Text("Choose how often you want to be reminded\nto move")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Picker("Interval", selection: $selectedMinutes) {
                ForEach(intervalOptions, id: \.self) { minute in
                    Text("\(minute) min").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)

            Button(action: {
                timeRemaining = selectedMinutes * 60
                isPresented = false
            }) {
                Text("Set Time")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeOrange)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 24)

            Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
                    .fontWeight(.bold)
                    .foregroundColor(themeOrange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(lightOrange)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(white: 0.98).ignoresSafeArea(.container, edges: .bottom))
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
