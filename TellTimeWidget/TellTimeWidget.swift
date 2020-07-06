import WidgetKit
import SwiftUI
import Intents
import SwiftPastTen
import SwiftClockUI

struct Provider: IntentTimelineProvider {
    public func snapshot(
        for configuration: ConfigurationIntent,
        with context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    public func timeline(
        for configuration: ConfigurationIntent,
        with context: Context,
        completion: @escaping (Timeline<Entry>) -> Void
    ) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            guard let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) else {
                continue
            }
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    public let configuration: ConfigurationIntent
}

struct PlaceholderView: View {
    var body: some View {
        TellTimeWidgetView(
            date: Date(),
            calendar: .autoupdatingCurrent
        )
    }
}

struct TellTimeWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        TellTimeWidgetView(
            date: entry.date,
            calendar: .autoupdatingCurrent
        )
    }
}

struct TellTimeWidgetView: View {
    let date: Date
    let calendar: Calendar

    var body: some View {
        VStack {
            ClockView().allowsHitTesting(false)
            Spacer()
            Text(SwiftPastTen.formattedDate(date, calendar: calendar))
            Spacer()
        }.padding()
    }
}

@main
struct TellTimeWidget: Widget {
    private let kind: String = "TellTimeWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider(),
            placeholder: PlaceholderView()
        ) { entry in
            TellTimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tell Time UK")
        .description("Widget for help you telling you the time the British English way.")
    }
}

struct TellTimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        TellTimeWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
