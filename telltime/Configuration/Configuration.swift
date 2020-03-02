import SwiftClockUI

enum Configuration {
    struct State {
        var clock = ClockConfiguration()
        var clockStyle: ClockStyle = .classic
    }

    enum Action {
        case showMinuteIndicators(Bool)
        case showHourIndicators(Bool)
        case showLimitedHours(Bool)
        case changeClockStyle(ClockStyle)
    }

    static func reducer(state: inout Configuration.State, action: Configuration.Action) {
        switch action {
        case let .showMinuteIndicators(isShown):
            state.clock.isMinuteIndicatorsShown = isShown
        case let .showHourIndicators(isShown):
            state.clock.isHourIndicatorsShown = isShown
        case let .showLimitedHours(isShown):
            state.clock.isLimitedHoursShown = isShown
        case let .changeClockStyle(clockStyle):
            state.clockStyle = clockStyle
        }
    }
}
