import SwiftUI

func randomDate(calendar: Calendar) -> Date {
    let hour = [Int](1...12).randomElement() ?? 0
    let minute = [Int](0...59).randomElement() ?? 0
    return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: .epoch) ?? .epoch
}

private extension Date {
    static var epoch: Date { .init(timeIntervalSince1970: 0) }
}
