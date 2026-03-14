//
//  ExerciseSessionView.swift
//  HeltekApp
//
//  Created by Brian Anashari on 11/03/26.
//

import SwiftUI
import UIKit
import ImageIO

struct ExerciseSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var didCompleteSession: Bool

    // MARK: - Session State
    @State private var sessionSteps: [ExerciseStep] = []
    @State private var currentIndex: Int = 0
    @State private var totalRemaining: Int = 60
    @State private var currentRemaining: Int = 20
    @State private var isPaused: Bool = false
    @State private var timerTask: Task<Void, Never>?

    // MARK: - Colors
    private let bgColor = Color(red: 0.98, green: 0.98, blue: 0.99)
    private let darkText = Color(red: 0.08, green: 0.12, blue: 0.18)
    private let grayText = Color(red: 0.58, green: 0.62, blue: 0.68)
    private let primaryOrange = Color(red: 0.93, green: 0.44, blue: 0.24)
    private let lightOrangeBg = Color(red: 0.98, green: 0.91, blue: 0.89)

    init(didCompleteSession: Binding<Bool> = .constant(false)) {
        _didCompleteSession = didCompleteSession
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    timerSection

                    activeExerciseSection

                    upNextSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }

            bottomAction
        }
        .background(bgColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startSessionIfNeeded()
        }
        .onDisappear {
            timerTask?.cancel()
        }
    }

    private var header: some View {
        HStack {
            Color.clear
                .frame(width: 40, height: 40)

            Spacer()

            Text("Let's Stretching")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(darkText)

            Spacer()

            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var timerSection: some View {
        ZStack {
            Circle()
                .stroke(primaryOrange.opacity(0.2), lineWidth: 10)
                .frame(width: 190, height: 190)

            Circle()
                .trim(from: 0, to: CGFloat(totalRemaining) / 60.0)
                .stroke(primaryOrange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 190, height: 190)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.2), value: totalRemaining)

            VStack(spacing: 8) {
                Text(timeString(from: totalRemaining))
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(darkText)

                Text("REMAINING")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(grayText)
                    .tracking(1.5)

                Button(action: { isPaused.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text(isPaused ? "Resume" : "Pause")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(darkText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.top, 8)
    }

    private var activeExerciseSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Active Stretching")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(darkText)

                Spacer()

                Text("STEP \(min(currentIndex + 1, sessionSteps.count))/\(sessionSteps.count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(primaryOrange)
                    .tracking(1.0)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(lightOrangeBg)
                    .clipShape(Capsule())
            }

            activeExerciseCard
        }
    }

    private var activeExerciseCard: some View {
        let step = currentStep

        return VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)

                GeometryReader { geo in
                    Group {
                        if let gifName = step?.motionGifName {
                            GifImageView(assetName: gifName)
                                .scaleEffect(0.5)
                        } else if let imageName = step?.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.5)
                        } else {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 48))
                                .foregroundColor(grayText)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(primaryOrange, lineWidth: 2)
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(step?.title ?? "")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(darkText)

                Text("\(currentRemaining)s left")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(primaryOrange)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)

                    Capsule()
                        .fill(primaryOrange)
                        .frame(width: progressWidth(for: currentRemaining), height: 6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(primaryOrange, lineWidth: 2)
        )
    }

    private var upNextSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Up Next")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(darkText)

            VStack(spacing: 12) {
                ForEach(upNextSteps, id: \.id) { step in
                    ExerciseUpcomingRowView(
                        title: step.title,
                        duration: "20 SECONDS",
                        imageName: step.imageName
                    )
                }
            }
        }
    }

    private var bottomAction: some View {
        VStack(spacing: 12) {
            Divider()

            Button(action: { endSession() }) {
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
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(bgColor)
    }

    private var currentStep: ExerciseStep? {
        guard currentIndex < sessionSteps.count else { return nil }
        return sessionSteps[currentIndex]
    }

    private var upNextSteps: [ExerciseStep] {
        guard currentIndex + 1 < sessionSteps.count else { return [] }
        return Array(sessionSteps[(currentIndex + 1)...])
    }

    private func progressWidth(for secondsLeft: Int) -> CGFloat {
        let ratio = max(0, min(1, CGFloat(secondsLeft) / 20.0))
        return 180 * ratio
    }

    private func startSessionIfNeeded() {
        guard sessionSteps.isEmpty else { return }

        didCompleteSession = false
        let steps = ExercisePlan.mockData
        let categoryA = steps.first?.steps.randomElement()
        let categoryB = steps.dropFirst().first?.steps.randomElement()
        let categoryC = steps.dropFirst(2).first?.steps.randomElement()

        sessionSteps = [categoryA, categoryB, categoryC].compactMap { $0 }
        currentIndex = 0
        totalRemaining = 60
        currentRemaining = 20
        isPaused = false

        startTimer()
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while totalRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !isPaused else { continue }

                totalRemaining -= 1
                currentRemaining -= 1

                if currentRemaining <= 0 {
                    advanceStep()
                }
            }

            sessionCompleted()
        }
    }

    private func advanceStep() {
        currentIndex += 1
        if currentIndex < sessionSteps.count {
            currentRemaining = 20
        } else {
            currentRemaining = 0
        }
    }

    @MainActor
    private func sessionCompleted() {
        Task {
            do {
                print("🟠 sessionCompleted: recording exercise session")
                try await FirebaseManager.shared.recordExerciseSession(
                    durationSeconds: 60,
                    stretches: sessionSteps.count
                )
                print("✅ sessionCompleted: record success")
            } catch {
                print("❌ Failed to record session: \(error.localizedDescription)")
            }
            didCompleteSession = true
            dismiss()
        }
    }

    private func endSession() {
        timerTask?.cancel()
        didCompleteSession = false
        dismiss()
    }

    private func timeString(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Subviews

private struct ExerciseUpcomingRowView: View {
    let title: String
    let duration: String
    let imageName: String

    private let darkText = Color(red: 0.08, green: 0.12, blue: 0.18)
    private let grayText = Color(red: 0.58, green: 0.62, blue: 0.68)

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(6)
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

private struct GifImageView: UIViewRepresentable {
    let assetName: String
    let contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.image = UIImage.animatedImage(from: assetName)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = UIImage.animatedImage(from: assetName)
    }
}
private extension UIImage {
    static func animatedImage(from assetName: String) -> UIImage? {
        if let dataAsset = NSDataAsset(name: assetName),
           let animated = animatedImage(from: dataAsset.data) {
            return animated
        }
        if let url = Bundle.main.url(forResource: assetName, withExtension: "gif"),
           let data = try? Data(contentsOf: url),
           let animated = animatedImage(from: data) {
            return animated
        }
        return UIImage(named: assetName)
    }

    static func animatedImage(from data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: TimeInterval = 0

        for index in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            let delay = frameDelay(for: source, at: index)
            duration += delay
            images.append(UIImage(cgImage: cgImage))
        }

        if duration == 0 { duration = Double(count) * 0.1 }
        return UIImage.animatedImage(with: images, duration: duration)
    }

    static func frameDelay(for source: CGImageSource, at index: Int) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifInfo = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else { return 0.1 }

        let unclampedDelay = gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber
        let delay = unclampedDelay ?? (gifInfo[kCGImagePropertyGIFDelayTime] as? NSNumber) ?? 0.1
        return max(0.02, delay.doubleValue)
    }
}

#Preview {
    ExerciseSessionView()
}
