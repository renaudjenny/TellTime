import SwiftUI
import Combine

final class Store: ObservableObject {
  private(set) var tts = TTS()

  private(set) var disposables = Set<AnyCancellable>()

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
    self.$date
      .sink(receiveValue: { date in
        guard !self.isSpeaking else { return }
        self.tts.speech(text: DigitalTime.from(date: date))
      })
      .store(in: &self.disposables)

    self.$showClockFace
      .filter({ $0 == true })
      .delay(for: 2.0, scheduler: RunLoop.main)
      .sink(receiveValue: { _ in
        self.showClockFace = false
      })
      .store(in: &self.disposables)

    self.tts.isSpeaking
      .assign(to: \.isSpeaking, on: self)
      .store(in: &self.disposables)
  }
}
