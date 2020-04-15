import SwiftUI
import SwiftPastTen

struct TellTimeKey: EnvironmentKey {
    static let defaultValue: (Date, Calendar) -> String = {
        let time = SwiftPastTen.formattedDate($0, calendar: $1)
        guard let tellTime = try? SwiftPastTen().tell(time: time) else { return "" }
        return tellTime
    }
}

extension EnvironmentValues {
    var tellTime: (Date, Calendar) -> String {
        get { self[TellTimeKey.self] }
        set { self[TellTimeKey.self] = newValue }
    }
}
