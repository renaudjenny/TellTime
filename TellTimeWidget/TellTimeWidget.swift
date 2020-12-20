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
            calendar: entry.calendar,
            design: entry.configuration.design
        )
    }
}

struct TellTimeWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let date: Date
    let calendar: Calendar
    let design: Design

    var body: some View {
        switch family {
        case .systemSmall: smallView
        case .systemMedium: mediumView
        case .systemLarge: largeView
        default: Text("Error")
        }
    }

    private var smallView: some View {
        VStack {
            switch design {
            case .unknown, .text: Text(time).padding()
            default: clock.padding()
            }
        }
        .widgetURL(url())
    }

    private var mediumView: some View {
        HStack {
            clock
            VStack {
                Text(time)
                Spacer()
                Link(destination: url(speak: true)) {
                    speakButton
                }
            }
        }
        .padding()
        .widgetURL(url())
    }

    private var largeView: some View {
        VStack {
            clock
            Spacer()
            HStack {
                Spacer()
                Text(time)
                Spacer()
                Link(destination: url(speak: true)) {
                    speakButton
                }
            }
            Spacer()
        }
        .padding()
        .widgetURL(url())
    }

    private var formattedTime: String {
        SwiftPastTen.formattedDate(date, calendar: calendar)
    }

    private var time: String {
        guard let time = try? SwiftPastTen().tell(time: formattedTime) else {
            return ""
        }
        return time
    }

    private var clock: some View {
        ClockView()
            .allowsHitTesting(false)
            .environment(\.clockDate, .constant(date))
            .environment(\.clockStyle, design.clockStyle)
    }

    private var speakButton: some View {
        Image(systemName: "speaker.2")
            .foregroundColor(.white)
            .padding()
            .cornerRadius(8)
            .background(Color.red.cornerRadius(8))
    }

    private func url(speak: Bool = false) -> URL {
        var urlComponents = URLComponents()
        urlComponents.host = "renaud.jenny.telltime"
        urlComponents.queryItems = [
            URLQueryItem(name: "clockStyle", value: "\(design.clockStyle.id)"),
            URLQueryItem(name: "speak", value: "\(speak)"),
        ]
        guard let url = urlComponents.url else {
            fatalError("Cannot build the URL from the Widget")
        }
        return url
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

extension Design {
    var clockStyle: ClockStyle {
        switch self {
        case .unknown, .classic, .text: return .classic
        case .artNouveau: return .artNouveau
        case .drawing: return .drawing
        case .steampunk: return .steampunk
        }
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
