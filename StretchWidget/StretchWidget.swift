//
//  StretchWidget.swift
//  StretchWidget
//
//  Created by Valentino Hartanto on 13/03/26.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), endDate: Date().addingTimeInterval(60))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), endDate: Date().addingTimeInterval(60))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Demo countdown values (refresh hourly). Replace with shared data if needed.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let endDate = entryDate.addingTimeInterval(60)
            let entry = SimpleEntry(date: entryDate, endDate: endDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let endDate: Date
}

struct StretchWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Focus Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Next movement")
                        .font(.headline)
                }
                Spacer(minLength: 8)
                Text(timerInterval: Date.now...entry.endDate, countsDown: true)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }

            Text("Keep your body active")
                .font(.caption2)
                .foregroundColor(.secondary)

            Spacer(minLength: 0)

            Text("Heltek")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

struct StretchWidget: Widget {
    let kind: String = "StretchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                StretchWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                StretchWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    StretchWidget()
} timeline: {
    SimpleEntry(date: .now, endDate: .now.addingTimeInterval(60))
    SimpleEntry(date: .now, endDate: .now.addingTimeInterval(300))
}
