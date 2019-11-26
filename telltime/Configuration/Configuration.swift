enum Configuration {
  struct State {
    var isMinuteIndicatorsShown: Bool = true
    var isHourIndicatorsShown: Bool = true
    var isLimitedHoursShown: Bool = false
    var speechRateRatio: Float = 1.0
    var clockStyle: ClockStyle = .classic
  }

  enum Action {
    case shownMinuteIndicators(Bool)
    case showHourIndicators(Bool)
    case showLimitedHours(Bool)
    case changeSpeechRateRatio(Float)
    case changeClockStyle(ClockStyle)
  }

  static let reducer: Reducer<Configuration.State, Configuration.Action> = Reducer { state, action in
    switch action {
    case let .shownMinuteIndicators(isShown):
      state.isMinuteIndicatorsShown = isShown
    case let .showHourIndicators(isShown):
      state.isHourIndicatorsShown = isShown
    case let .showLimitedHours(isShown):
      state.isLimitedHoursShown = isShown
    case let .changeSpeechRateRatio(ratio):
      state.speechRateRatio = ratio
    case let .changeClockStyle(clockStyle):
      state.clockStyle = clockStyle
    }
  }
}
