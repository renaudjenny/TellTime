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

  enum SideEffect: Effect {
    case delayClockFaceHidding

    func mapToAction() -> AnyPublisher<Clock.Action, Never> {
      switch self {
      case .delayClockFaceHidding:
        return Just(true)
          .delay(for: .seconds(2), scheduler: RunLoop.main)
          .map { _ in Clock.Action.hideClockFace }
          .eraseToAnyPublisher()
      }
    }
  }

  static let reducer: Reducer<Clock.State, Clock.Action> = Reducer { state, action in
    func changeDateAndAngles(date: Date) {
      state.date = date
      state.hourAngle = .fromHour(date: state.date)
      state.minuteAngle = .fromMinute(date: state.date)
    }

    switch action {
    case .changeClockRandomly:
      let hour = [Int](1...12).randomElement() ?? 0
      let minute = [Int](0...59).randomElement() ?? 0
      changeDateAndAngles(date: .from(hour: hour, minute: minute))
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
    let minute = Calendar.current.component(.minute, from: self)

    return Calendar.current.date(
      bySettingHour: Int(hour.rounded()), minute: minute, second: 0,
      of: self
    ) ?? self
  }

  func with(minuteAngle angle: Angle) -> Date {
    let minute = angle.degrees.positiveDegrees/Self.minuteRelationsip
    let hour = Calendar.current.component(.hour, from: self)

    return Calendar.current.date(
      bySettingHour: hour, minute: Int(minute.rounded()), second: 0,
      of: self
    ) ?? self
  }

  static func from(hour: Int, minute: Int) -> Date {
    return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Current.date()) ?? Current.date()
  }
}
