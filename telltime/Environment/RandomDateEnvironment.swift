import SwiftUI

struct RandomDateKey: EnvironmentKey {
    static let defaultValue: (Calendar, Date) -> Date = { calendar, date in
        let hour = [Int](1...12).randomElement() ?? 0
        let minute = [Int](0...59).randomElement() ?? 0
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
}

extension EnvironmentValues {
    var randomDate: (Calendar, Date) -> Date {
        get { self[RandomDateKey.self] }
        set { self[RandomDateKey.self] = newValue }
    }
}
