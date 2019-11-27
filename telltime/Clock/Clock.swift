import SwiftUI
import Combine
import Foundation

enum Clock {
  struct State {
    var date: Date = Date()
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
    switch action {
    case .changeClockRandomly:
      let hour = [Int](1...12).randomElement() ?? 0
      let minute = [Int](0...59).randomElement() ?? 0
      state.date = Date() // FIXME: TODO
      // TODO: speech
    case .showClockFace:
      state.isClockFaceShown = true
    case .hideClockFace:
      state.isClockFaceShown = false
    case let .changeHourAngle(angle):
      state.hourAngle = angle
      state.date.setHourAngle(angle)
    case let .changeMinuteAngle(angle):
      state.minuteAngle = angle
      state.date.setMinuteAngle(angle)
    case let .changeDate(date):
      state.date = date
      // TODO: speech
    }
  }
}

private extension Date {
  private static let hourRelationship: Double = 360/12
  private static let minuteRelationsip: Double = 360/60

  mutating func setHourAngle(_ angle: Angle) {
    let positiveDegrees = angle.degrees.positiveDegrees
    let hour = positiveDegrees/Self.hourRelationship
    let minute = Calendar.current.component(.minute, from: self)

    self = Calendar.current.date(
      bySettingHour: Int(hour.rounded()), minute: minute, second: 0,
      of: self
    ) ?? self
  }

  mutating func setMinuteAngle(_ angle: Angle) {
    let minute = angle.degrees.positiveDegrees/Self.minuteRelationsip
    let hour = Calendar.current.component(.hour, from: self)

    self = Calendar.current.date(
      bySettingHour: hour, minute: Int(minute.rounded()), second: 0,
      of: self
    ) ?? self
  }
}
