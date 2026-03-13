//
//  ExercisePlanView.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import SwiftUI

struct ExercisePlanView: View {
    @StateObject private var viewModel = ExercisePlanViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.plans) { plan in
                        NavigationLink(value: plan) {
                            ExercisePlanCard(plan: plan)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color.themeBackground)
            .navigationTitle("Exercise Plans")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ExercisePlan.self) { plan in
                ExercisePlanDetailView(plan: plan)
            }
        }
    }
}

private struct ExercisePlanCard: View {
    let plan: ExercisePlan

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Image(plan.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.title)
                        .font(ThemeFont.bodyBold)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(plan.description)
                        .font(ThemeFont.caption)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                HStack(spacing: 12) {
                    PlanMetaChip(title: "\(plan.calories) kcal", iconName: "flame.fill")
                    PlanMetaChip(title: plan.targetArea, iconName: "figure.strengthtraining.traditional")

                    Spacer(minLength: 0)

                    DurationPill(text: plan.duration)
                }
            }
            .padding(16)
        }
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

private struct PlanMetaChip: View {
    let title: String
    let iconName: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textSecondary)
            Text(title)
                .font(ThemeFont.caption)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.themeBackground)
        .clipShape(Capsule())
    }
}
private struct CardShadow: ViewModifier {
    func body(content: Content) -> some View {
        ThemeStyle.cardShadow(for: content)
    }
}

#Preview {
    ExercisePlanView()
}

