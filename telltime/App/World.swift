import SwiftUI
import Combine
import SwiftPastTen

// TODO: Get rid of World and use Environment instead

// For more information check "How To Control The World" - Stephen Celis
// https://vimeo.com/291588126

struct World {
  var tellTime: (Date, Calendar) -> String = {
    let time = SwiftPastTen.formattedDate($0, calendar: $1)
    guard let tellTime = try? SwiftPastTen().tell(time: time) else { return "" }
    return tellTime
  }

  var tts = TTS.World()
}

extension TTS {
  struct World {
    private let engine: Engine

    var isSpeaking: Bool
    var isSpeakingPublisher: AnyPublisher<Bool, Never>
    var speakingProgressPublisher: AnyPublisher<Double, Never>
    var setRateRatio: (Float) -> Void
    var speech: (Date) -> Void

    init(engine: Engine = Engine(calendar: Calendar.autoupdatingCurrent)) {
      self.engine = engine
      self.isSpeaking = engine.isSpeaking
      self.isSpeakingPublisher = engine.$isSpeaking.eraseToAnyPublisher()
      self.speakingProgressPublisher = engine.$speakingProgress.eraseToAnyPublisher()
      self.setRateRatio = { engine.rateRatio = $0 }
      self.speech = { engine.speech(date: $0) }
    }
  }
}

var Current = World()
