import SwiftUI

struct RandomDateKey: EnvironmentKey {
    static let defaultValue: (Calendar) -> Date = { calendar in
        let hour = [Int](1...12).randomElement() ?? 0
        let minute = [Int](0...59).randomElement() ?? 0
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: .epoch) ?? .epoch
    }
}

extension EnvironmentValues {
    var randomDate: (Calendar) -> Date {
        get { self[RandomDateKey.self] }
        set { self[RandomDateKey.self] = newValue }
    }
}

private extension Date {
    static var epoch: Date { .init(timeIntervalSince1970: 0) }
}
