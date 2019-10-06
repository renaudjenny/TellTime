import SwiftUI
import Combine

final class Store: ObservableObject {
  private(set) var tts = TTS()

  private var subscribers: [Cancellable] = []

  @Published var isSpeaking = false

  @Published var date: Date = Date()

  var hour: Int {
    Calendar.current.component(.hour, from: self.date)
  }

  var minute: Int {
    Calendar.current.component(.minute, from: self.date)
  }

  @Published var showClockFace: Bool = false

  init() {
    self.subscribers.append(self.$date
      .debounce(for: 0.4, scheduler: RunLoop.main)
      .sink(receiveValue: { _ in
        self.tts.speech(text: DigitalTime.from(hour: self.hour, minute: self.minute))
      })
    )

    self.subscribers.append(self.$showClockFace
      .filter({ $0 == true })
      .delay(for: 2.0, scheduler: RunLoop.main)
      .sink(receiveValue: { _ in
        self.showClockFace = false
      })
    )

    self.subscribers.append(self.tts.isSpeaking
      .sink(receiveValue: { isSpeaking in
        self.isSpeaking = isSpeaking
      })
    )
  }
}
