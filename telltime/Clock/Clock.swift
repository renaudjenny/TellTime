import SwiftUI
import Combine

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
    case changeHourAngle(Angle)
    case changeMinuteAngle(Angle)
  }

  static let reducer: Reducer<Clock.State, Clock.Action> = Reducer { state, action in
    switch action {
    case .changeClockRandomly:
      let hour = [Int](1...12).randomElement() ?? 0
      let minute = [Int](0...59).randomElement() ?? 0
      state.date = Date() // FIXME: TODO
    case .showClockFace:
      state.isClockFaceShown = true
    case let .changeHourAngle(angle):
      state.hourAngle = angle
    case let .changeMinuteAngle(angle):
      state.minuteAngle = angle
    }
  }
}
// FIXME: TODO
//final class ClockStore: ObservableObject {
//  private var disposables = Set<AnyCancellable>()
//
//  init() {
//    self.hourAngle = .fromHour(date: self.date)
//    self.minuteAngle = .fromMinute(date: self.date)
//    self.subscribeArmAnglesChanged()
//    self.subscribeShowClockFaceChanged()
//  }
//}
//
//// MARK: - Arm Angles
//extension ClockStore {
//  private func subscribeArmAnglesChanged() {
//    self.$hourAngle
//      .dropFirst()
//      .sink { angle in
//        let date = self.date
//        let hourRelationship: Double = 360/12
//        let hour = angle.degrees.positiveDegrees/hourRelationship
//        let minute = Calendar.current.component(.minute, from: date)
//
//        guard let newDate = Calendar.current.date(
//          bySettingHour: Int(hour.rounded()), minute: minute, second: 0,
//          of: date
//        ) else { return }
//
//        self.date = newDate
//      }
//      .store(in: &self.disposables)
//
//    self.$minuteAngle
//      .dropFirst()
//      .sink { angle in
//        let date = self.date
//        let relationship: Double = 360/60
//        let minute = angle.degrees.positiveDegrees/relationship
//        let hour = Calendar.current.component(.hour, from: date)
//
//        guard let newDate = Calendar.current.date(
//          bySettingHour: hour, minute: Int(minute.rounded()), second: 0,
//          of: date
//        ) else { return }
//
//        self.date = newDate
//      }
//      .store(in: &self.disposables)
//  }
//}
//
//// MARK: - Clock Face
//extension ClockStore {
//  private func subscribeShowClockFaceChanged() {
//    self.$showClockFace
//      .filter({ $0 == true })
//      .delay(for: 2.0, scheduler: RunLoop.main)
//      .sink(receiveValue: { _ in
//        self.showClockFace = false
//      })
//      .store(in: &self.disposables)
//  }
//}
