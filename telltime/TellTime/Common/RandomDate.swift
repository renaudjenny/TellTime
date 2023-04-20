import Dependencies
import Foundation
import XCTestDynamicOverlay

public struct RandomDate {
    var randomDate: () -> Date

    public init(randomDate: @escaping () -> Date) {
        self.randomDate = randomDate
    }

    public func callAsFunction() -> Date {
        randomDate()
    }
}

private extension RandomDate {
    static let live = Self {
        @Dependency(\.calendar) var calendar
        let hour = [Int](1...12).randomElement() ?? 0
        let minute = [Int](0...59).randomElement() ?? 0
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: .epoch) ?? .epoch
    }
    static let preview = RandomDate.live
    static let test = Self(randomDate: unimplemented("RandomDate.randomDate"))
}

private extension Date {
    static var epoch: Date { .init(timeIntervalSince1970: 0) }
}

private enum RandomDateKey: DependencyKey {
    static let liveValue = RandomDate.live
    static let previewValue = RandomDate.preview
    static let testValue = RandomDate.test
}

extension DependencyValues {
    var randomDate: RandomDate {
        get { self[RandomDateKey.self] }
        set { self[RandomDateKey.self] = newValue }
    }
}
