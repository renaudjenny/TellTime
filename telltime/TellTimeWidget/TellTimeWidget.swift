import Intents
import SwiftUI
import WidgetFeature
import WidgetKit

struct Provider: IntentTimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
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
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let flooredDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        for minuteOffset in 0 ..< 60 {
            guard let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: flooredDate) else {
                continue
            }
            let entry = SimpleEntry(
                date: entryDate,
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
    public let configuration: ConfigurationIntent
}

struct TellTimeWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        WidgetView(date: entry.date, design: entry.configuration.design.rawValue)
    }
}

@main
struct TellTimeWidget: SwiftUI.Widget {
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

#if DEBUG
struct WidgetView_Previews: PreviewProvider {
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
                    configuration: ConfigurationIntent()
                )
            )
        }
    }
}
#endif
