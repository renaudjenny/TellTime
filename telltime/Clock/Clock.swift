import SwiftUI
import Combine
import Foundation

enum Clock {
  struct State {
    var date: Date = Current.date()
    var hourAngle: Angle = .zero
    var minuteAngle: Angle = .zero
    var isClockFaceShown: Bool = false
  }

  enum Action {
    case changeClockRandomly
    case showClockFace
    case hideClockFace
    case changeHourAngle(Angle)
    case changeMinuteAngle(Angle)
    case changeDate(Date)
  }

  static func delayClockFaceHidding() -> AnyPublisher<App.Action, Never> {
    Just(true)
      .delay(for: .seconds(Current.clockFaceShownTimeInterval), scheduler: RunLoop.main)
      .map { _ in .clock(.hideClockFace) }
      .eraseToAnyPublisher()
  }

  static func reducer(state: inout Clock.State, action: Clock.Action) {
    func changeDateAndAngles(date: Date) {
      state.date = date
      state.hourAngle = .fromHour(date: state.date)
      state.minuteAngle = .fromMinute(date: state.date)
    }

    switch action {
    case .changeClockRandomly:
      changeDateAndAngles(date: Current.randomDate())
    case .showClockFace:
      state.isClockFaceShown = true
    case .hideClockFace:
      state.isClockFaceShown = false
    case let .changeHourAngle(angle):
      changeDateAndAngles(date: state.date.with(hourAngle: angle))
    case let .changeMinuteAngle(angle):
      changeDateAndAngles(date: state.date.with(minuteAngle: angle))
    case let .changeDate(date):
      changeDateAndAngles(date: date)
    }
  }
}

private extension Date {
  private static let hourRelationship: Double = 360/12
  private static let minuteRelationsip: Double = 360/60

  func with(hourAngle angle: Angle) -> Date {
    let positiveDegrees = angle.degrees.positiveDegrees
    let hour = positiveDegrees/Self.hourRelationship
    let minute = Current.calendar.component(.minute, from: self)

    return Current.calendar.date(
      bySettingHour: Int(hour.rounded()), minute: minute, second: 0,
      of: self
    ) ?? self
  }

  func with(minuteAngle angle: Angle) -> Date {
    let minute = angle.degrees.positiveDegrees/Self.minuteRelationsip
    let hour = Current.calendar.component(.hour, from: self)

    return Current.calendar.date(
      bySettingHour: hour, minute: Int(minute.rounded()), second: 0,
      of: self
    ) ?? self
  }
}
