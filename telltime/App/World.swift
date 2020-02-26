import SwiftUI
import Combine
import SwiftPastTen

// For more information check "How To Control The World" - Stephen Celis
// https://vimeo.com/291588126

struct World {
  var date = { Date() }
  var calendar = Calendar.autoupdatingCurrent
  var randomDate: () -> Date = {
    let hour = [Int](1...12).randomElement() ?? 0
    let minute = [Int](0...59).randomElement() ?? 0
    return Current.calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Current.date()) ?? Current.date()
  }
  var clockFaceShownTimeInterval: TimeInterval = 2
  var deviceOrientation = UIDevice.current.orientation
  var orientationDidChangePublisher = NotificationCenter.default
    .publisher(for: UIDevice.orientationDidChangeNotification)

  var isAnimationDisabled = false
  var tellTime: (Date) -> String = {
    let time = SwiftPastTen.formattedDate($0, calendar: Current.calendar)
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

    init(engine: Engine = Engine()) {
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
