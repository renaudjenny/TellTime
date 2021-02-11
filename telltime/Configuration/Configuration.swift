import SwiftClockUI

struct ConfigurationState: Equatable {
    var clock = ClockConfiguration()
    var clockStyle: ClockStyle = .classic
}

enum ConfigurationAction {
    case showMinuteIndicators(Bool)
    case showHourIndicators(Bool)
    case showLimitedHours(Bool)
    case changeClockStyle(ClockStyle)
}

func configurationReducer(state: inout ConfigurationState, action: ConfigurationAction) {
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

// TODO: should be done in the library directly
extension ClockConfiguration: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.isLimitedHoursShown == rhs.isLimitedHoursShown
        && lhs.isMinuteIndicatorsShown == rhs.isMinuteIndicatorsShown
        && lhs.isHourIndicatorsShown == rhs.isHourIndicatorsShown
    }
}
