import SwiftUI
import Combine
import SwiftPastTen

// TODO: Get rid of World and use Environment instead

// For more information check "How To Control The World" - Stephen Celis
// https://vimeo.com/291588126

struct World {
  var tts = TTS.World()
}

extension TTS {
  struct World {
    private let engine: Engine

    var isSpeakingPublisher: AnyPublisher<Bool, Never>
    var speakingProgressPublisher: AnyPublisher<Double, Never>

    init(engine: Engine = Engine(
        tellTime: { _, _ in "TTS Not available anymore" },
        calendar: Calendar.autoupdatingCurrent)
    ) {
      self.engine = engine
      self.isSpeakingPublisher = engine.$isSpeaking.eraseToAnyPublisher()
      self.speakingProgressPublisher = engine.$speakingProgress.eraseToAnyPublisher()
    }
  }
}

var Current = World()
