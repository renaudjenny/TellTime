import Dependencies
import SwiftClockUI
import SwiftUI
import SwiftPastTenDependency
import WidgetKit

public struct WidgetView: View {
    let date: Date
    let design: Design
    @Environment(\.widgetFamily) var family: WidgetFamily

    public init(date: Date, design: Int) {
        self.date = date
        self.design = Design(rawValue: design) ?? .classic
    }

    public var body: some View {
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

    private var time: String {
        @Dependency(\.calendar) var calendar
        @Dependency(\.tellTime) var tellTime
        guard let time = try? tellTime(time: SwiftPastTen.formattedDate(date, calendar: calendar))
        else { return "" }
        return time
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

/// Design needs to be a perfect match with TellTimeWidget Design
enum Design: Int {
    case unknown
    case classic
    case artNouveau
    case drawing
    case steampunk
    case text
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
