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
        Text(time).padding()
    }

    @ViewBuilder
    private var mediumView: some View {
        if design == .lewis {
            HStack {
                clock
                digital
            }.padding()
        } else {
            HStack {
                clock
                Text(time)
            }.padding()
        }
    }

    private var largeView: some View {
        VStack {
            clock
            Spacer()
            Text(time)
            Spacer()
        }.padding()
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

    private var clockStyle: ClockStyle {
        switch design {
        case .unknown: return .classic
        case .classic: return .classic
        case .drawing: return .drawing
        case .artNouveau: return .artNouveau
        case .steampunk: return .steampunk
        default: return .classic
        }
    }

    @ViewBuilder
    private var clock: some View {
        ClockView()
            .allowsHitTesting(false)
            .environment(\.clockDate, .constant(date))
            .environment(\.clockStyle, clockStyle)
    }

    private var digital: some View {
        GeometryReader { (geometry: GeometryProxy) in
            VStack {
                Spacer()
                Text(formattedTime)
                    .font(
                        .system(
                            size: min(geometry.size.width, geometry.size.height) * 1/4,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .padding()
                Spacer()
            }
        }
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
