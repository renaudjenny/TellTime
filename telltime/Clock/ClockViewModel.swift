import SwiftUI
import Combine

final class ClockViewModel: ObservableObject, Identifiable {
  @Published var date: Binding<Date>
  @Published var showClockFace: Bool

  init(date: Binding<Date>, showClockFace: Bool) {
    self.date = date
    self.showClockFace = showClockFace
  }
}
