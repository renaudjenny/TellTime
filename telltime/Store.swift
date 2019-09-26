import SwiftUI
import Combine

final class Store: ObservableObject  {
  @Published var date: Date = Date()

  var hour: Int {
    Calendar.current.component(.hour, from: self.date)
  }

  var minute: Int {
    Calendar.current.component(.minute, from: self.date)
  }

  init() {
    _ = self.objectWillChange
    .debounce(for: 0.4, scheduler: RunLoop.main)
    .sink(receiveValue: {
      TTS(hour: self.hour, minute: self.minute)
        .speechTime()
    })
  }
}
