import SwiftUI
import Combine

final class Store: ObservableObject {
  @Published var date: Date = Date()

  var hour: Int {
    Calendar.current.component(.hour, from: self.date)
  }

  var minute: Int {
    Calendar.current.component(.minute, from: self.date)
  }

  @Published var showClockFace: Bool = false

  init() {
    _ = self.$date
      .debounce(for: 0.4, scheduler: RunLoop.main)
      .sink(receiveValue: { _ in
        TTS(hour: self.hour, minute: self.minute)
          .speechTime()
      })

    _ = self.$showClockFace
      .filter({ $0 == true })
      .delay(for: 2.0, scheduler: RunLoop.main)
      .sink(receiveValue: { _ in
        self.showClockFace = false
      })
  }
}
