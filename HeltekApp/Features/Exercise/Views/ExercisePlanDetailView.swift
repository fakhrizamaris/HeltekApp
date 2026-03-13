//
//  ExercisePlanDetailView.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import SwiftUI

struct ExercisePlanDetailView: View {
    let plan: ExercisePlan

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeroHeader(plan: plan)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Simple Exercises")
                            .font(ThemeFont.bodyBold)
                            .foregroundColor(.textPrimary)

                        Spacer(minLength: 0)

                        Text("\(plan.steps.count) steps")
                            .font(ThemeFont.caption)
                            .foregroundColor(Color.themePrimary)
                    }

                    VStack(spacing: 12) {
                        ForEach(plan.steps) { step in
                            ExerciseStepRow(step: step)
                        }
                    }
                }
                .padding(16)
                .background(Color.themeBackground)
            }
        }
        .background(Color.themeBackground)
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HeroHeader: View {
    let plan: ExercisePlan

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(plan.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 260)

            VStack(alignment: .leading, spacing: 8) {
                DurationPill(text: "\(plan.duration) plans")

                Text(plan.description)
                    .font(ThemeFont.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(16)
        }
    }
}

private struct ExerciseStepRow: View {
    let step: ExerciseStep

    var body: some View {
        HStack(spacing: 12) {
            Image(step.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(ThemeFont.bodyBold)
                    .foregroundColor(.textPrimary)

                Text(step.instruction)
                    .font(ThemeFont.caption)
                    .foregroundColor(Color.themePrimary.opacity(0.7))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: ThemeStyle.cornerRadius, style: .continuous))
        .modifier(CardShadow())
    }
}

private struct DurationPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(ThemeFont.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.themePrimary)
            .clipShape(Capsule())
    }
}

private struct CardShadow: ViewModifier {
    func body(content: Content) -> some View {
        ThemeStyle.cardShadow(for: content)
    }
}

#Preview {
    NavigationStack {
        ExercisePlanDetailView(plan: ExercisePlan.mockData.first!)
    }
}
