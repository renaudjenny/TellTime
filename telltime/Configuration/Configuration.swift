enum Configuration {
  struct State {
    var isMinuteIndicatorsShown: Bool = true
    var isHourIndicatorsShown: Bool = true
    var isLimitedHoursShown: Bool = false
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
      state.isMinuteIndicatorsShown = isShown
    case let .showHourIndicators(isShown):
      state.isHourIndicatorsShown = isShown
    case let .showLimitedHours(isShown):
      state.isLimitedHoursShown = isShown
    case let .changeClockStyle(clockStyle):
      state.clockStyle = clockStyle
    }
  }
}
