import SwiftUI
import Combine
import SwiftPastTen

final class ClockStore: ObservableObject {
  @Published var date: Date = Date()
  @Published var hourAngle: Angle = .zero
  @Published var minuteAngle: Angle = .zero
  @Published var showClockFace: Bool = false

  private var disposables = Set<AnyCancellable>()

  init() {
    self.hourAngle = .fromHour(date: self.date)
    self.minuteAngle = .fromMinute(date: self.date)
    self.subscribeArmAnglesChanged()
    self.subscribeShowClockFaceChanged()
  }
}

// MARK: - Arm Angles
extension ClockStore {
  private func subscribeArmAnglesChanged() {
    self.$hourAngle
      .dropFirst()
      .sink { angle in
        let date = self.date
        let hourRelationship: Double = 360/12
        let hour = angle.degrees.positiveDegrees/hourRelationship
        let minute = Calendar.current.component(.minute, from: date)

        guard let newDate = Calendar.current.date(
          bySettingHour: Int(hour.rounded()), minute: minute, second: 0,
          of: date
        ) else { return }

        self.date = newDate
      }
      .store(in: &self.disposables)

    self.$minuteAngle
      .dropFirst()
      .sink { angle in
        let date = self.date
        let relationship: Double = 360/60
        let minute = angle.degrees.positiveDegrees/relationship
        let hour = Calendar.current.component(.hour, from: date)

        guard let newDate = Calendar.current.date(
          bySettingHour: hour, minute: Int(minute.rounded()), second: 0,
          of: date
        ) else { return }

        self.date = newDate
      }
      .store(in: &self.disposables)
  }
}

// MARK: - Time
extension ClockStore {
  func changeClockRandomly() {
    let hour = [Int](1...12).randomElement() ?? 0
    let minute = [Int](0...59).randomElement() ?? 0

    guard let newDate = Calendar.current.date(
      byAdding: DateComponents(hour: hour, minute: minute),
      to: self.date
    ) else { return }

    self.date = newDate
  }
}

// MARK: - Clock Face
extension ClockStore {
  private func subscribeShowClockFaceChanged() {
    self.$showClockFace
      .filter({ $0 == true })
      .delay(for: 2.0, scheduler: RunLoop.main)
      .sink(receiveValue: { _ in
        self.showClockFace = false
      })
      .store(in: &self.disposables)
  }
}
