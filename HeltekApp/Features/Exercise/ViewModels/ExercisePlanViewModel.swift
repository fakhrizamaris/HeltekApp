//
//  ExercisePlanViewModel.swift
//  HeltekApp
//
//  Created by Valentino Hartanto on 11/03/26.
//

import Combine

final class ExercisePlanViewModel: ObservableObject {
    @Published private(set) var plans: [ExercisePlan]

    init(plans: [ExercisePlan] = ExercisePlan.mockData) {
        self.plans = plans
    }
}
