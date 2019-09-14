import SwiftUI
import Combine

final class Store: ObservableObject  {
  @Published var date: Date = Date() {
    didSet {
      TTS(hour: self.hour, minute: self.minute)
        .speechTime()
    }
  }

  var hour: Int {
    Calendar.current.component(.hour, from: self.date)
  }

  var minute: Int {
    Calendar.current.component(.minute, from: self.date)
  }
}
