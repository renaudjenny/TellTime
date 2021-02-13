import SwiftClockUI
import ComposableArchitecture

struct ConfigurationState: Equatable {
    var clock = ClockConfiguration()
    var clockStyle: ClockStyle = .classic
    var isPresented = false
}

enum ConfigurationAction: Equatable {
    case setMinuteIndicatorsShown(Bool)
    case setHourIndicatorsShown(Bool)
    case setLimitedHoursShown(Bool)
    case setClockStyle(ClockStyle)
    case present
    case hide
}

struct ConfigurationEnvironment { }

let configurationReducer = Reducer<ConfigurationState, ConfigurationAction, ConfigurationEnvironment> { state, action, environment in
    switch action {
    case let .setMinuteIndicatorsShown(isShown):
        state.clock.isMinuteIndicatorsShown = isShown
        return .none
    case let .setHourIndicatorsShown(isShown):
        state.clock.isHourIndicatorsShown = isShown
        return .none
    case let .setLimitedHoursShown(isShown):
        state.clock.isLimitedHoursShown = isShown
        return .none
    case let .setClockStyle(clockStyle):
        state.clockStyle = clockStyle
        return .none
    case .present:
        state.isPresented = true
        return .none
    case .hide:
        state.isPresented = false
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
