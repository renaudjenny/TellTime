import SwiftUI

struct DateKey: EnvironmentKey {
    static let defaultValue: () -> Date = Date.init
}

extension EnvironmentValues {
    var date: () -> Date {
        get { self[DateKey.self] }
        set { self[DateKey.self] = newValue }
    }
}
