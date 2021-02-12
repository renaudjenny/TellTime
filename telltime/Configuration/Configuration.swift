import SwiftClockUI
import ComposableArchitecture

struct ConfigurationState: Equatable {
    var clock = ClockConfiguration()
    var clockStyle: ClockStyle = .classic
}

enum ConfigurationAction: Equatable {
    case showMinuteIndicators(Bool)
    case showHourIndicators(Bool)
    case showLimitedHours(Bool)
    case changeClockStyle(ClockStyle)
}

struct ConfigurationEnvironment { }

let configurationReducer = Reducer<ConfigurationState, ConfigurationAction, ConfigurationEnvironment> { state, action, environment in
    switch action {
    case let .showMinuteIndicators(isShown):
        state.clock.isMinuteIndicatorsShown = isShown
        return .none
    case let .showHourIndicators(isShown):
        state.clock.isHourIndicatorsShown = isShown
        return .none
    case let .showLimitedHours(isShown):
        state.clock.isLimitedHoursShown = isShown
        return .none
    case let .changeClockStyle(clockStyle):
        state.clockStyle = clockStyle
        return .none
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
