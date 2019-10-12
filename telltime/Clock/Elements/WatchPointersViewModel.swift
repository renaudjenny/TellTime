import SwiftUI
import Combine

final class WatchPointersViewModel: ObservableObject, Identifiable {
  @Published var date: Binding<Date>
  @ObservedObject var hourWatchPointerViewModel: WatchPointerViewModel
  @ObservedObject var minuteWatchPointerViewModel: WatchPointerViewModel

  private var disposables = Set<AnyCancellable>()

  init(date: Binding<Date>) {
    self.date = date
    self.hourWatchPointerViewModel = WatchPointerViewModel(
      rotationAngle: Self.hourIntoAngle(date: date.wrappedValue),
      dragEndedRotationAngle: Angle(degrees: .zero)
    )
    self.minuteWatchPointerViewModel = WatchPointerViewModel(
      rotationAngle: Self.minuteIntoAngle(date: date.wrappedValue),
      dragEndedRotationAngle: Angle(degrees: .zero)
    )

    self.subscribe()
  }

  private static func hourIntoAngle(date: Date) -> Angle {
    let minute = Double(Calendar.current.component(.minute, from: date))
    let minuteInHour = minute > 0 ? minute/60 : 0
    let hour = Double(Calendar.current.component(.hour, from: date)) + minuteInHour

    let relationship: Double = 360/12
    let degrees = hour * relationship
    return Angle(degrees: degrees)
  }

  private static func minuteIntoAngle(date: Date) -> Angle {
    let minute = Double(Calendar.current.component(.minute, from: date))
    let relationship: Double = 360/60
    return Angle(degrees: Double(minute) * relationship)
  }

  private func subscribe() {
    self.hourWatchPointerViewModel.$dragEndedRotationAngle
      .dropFirst()
      .sink { angle in
        let date = self.date.wrappedValue
        let hourRelationship: Double = 360/12
        let hour = angle.degrees.positiveDegrees/hourRelationship
        let minute = Calendar.current.component(.minute, from: date)

        guard let newDate = Calendar.current.date(
          bySettingHour: Int(hour.rounded()), minute: minute, second: 0,
          of: date
        ) else { return }

        self.date.wrappedValue = newDate
      }
      .store(in: &self.disposables)

    self.minuteWatchPointerViewModel.$dragEndedRotationAngle
      .dropFirst()
      .sink { angle in
        let date = self.date.wrappedValue
        let relationship: Double = 360/60
        let minute = angle.degrees.positiveDegrees/relationship
        let hour = Calendar.current.component(.hour, from: date)

        guard let newDate = Calendar.current.date(
          bySettingHour: hour, minute: Int(minute.rounded()), second: 0,
          of: date
        ) else { return }

        self.date.wrappedValue = newDate
      }
      .store(in: &self.disposables)
  }
}
