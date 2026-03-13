//
//  StretchWidgetBundle.swift
//  StretchWidget
//
//  Created by Valentino Hartanto on 13/03/26.
//

import WidgetKit
import SwiftUI

@main
struct StretchWidgetBundle: WidgetBundle {
    var body: some Widget {
        StretchWidget()
        StretchWidgetControl()
        StretchWidgetLiveActivity()
    }
}
