import WidgetKit
import SwiftUI
import Intents
import SwiftPastTen
import SwiftClockUI

struct Provider: IntentTimelineProvider {
    @Environment(\.calendar) private var calendar

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            calendar: calendar,
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        let entry = SimpleEntry(
            date: Date(),
            calendar: calendar,
            configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: ConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<SimpleEntry>) -> Void
    ) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of all minute entries an hour apart, starting from the current date.
        let currentDate = Date()
        for minuteOffset in 0 ..< 60 {
            guard let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate) else {
                continue
            }
            let entry = SimpleEntry(
                date: entryDate,
                calendar: calendar,
                configuration: configuration
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
    let calendar: Calendar
    public let configuration: ConfigurationIntent
}

struct TellTimeWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        TellTimeWidgetView(
            date: entry.date,
            calendar: entry.calendar
        )
    }
}

struct TellTimeWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let date: Date
    let calendar: Calendar

    var body: some View {
        switch family {
        case .systemSmall: smallView
        case .systemMedium: mediumView
        case .systemLarge: largeView
        default: Text("Error")
        }
    }

    private var smallView: some View {
        Text(time).padding()
    }

    private var mediumView: some View {
        HStack {
            ClockView()
                .allowsHitTesting(false)
                .environment(\.clockDate, .constant(date))
            Text(time)
        }.padding()
    }

    private var largeView: some View {
        VStack {
            ClockView()
                .allowsHitTesting(false)
                .environment(\.clockDate, .constant(date))
            Spacer()
            Text(time)
            Spacer()
        }.padding()
    }

    private var time: String {
        let formattedString = SwiftPastTen.formattedDate(date, calendar: calendar)
        guard let time = try? SwiftPastTen().tell(time: formattedString) else {
            return ""
        }
        return time
    }
}

@main
struct TellTimeWidget: Widget {
    private let kind: String = "TellTimeWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            TellTimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tell Time UK")
        .description("Widget for help you telling you the time the British English way.")
    }
}

struct TellTimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Preview().previewContext(WidgetPreviewContext(family: .systemSmall))
            Preview().previewContext(WidgetPreviewContext(family: .systemMedium))
            Preview().previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }

    private struct Preview: View {
        @Environment(\.calendar) private var calendar

        var body: some View {
            TellTimeWidgetEntryView(
                entry: SimpleEntry(
                    date: Date(),
                    calendar: calendar,
                    configuration: ConfigurationIntent()
                )
            )
        }
    }
}
