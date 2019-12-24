import SwiftUI
import Combine

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
  var deviceOrientation = UIDevice.current.orientation
  var orientationDidChangePublisher = NotificationCenter.default
    .publisher(for: UIDevice.orientationDidChangeNotification)

  var tts = TTS.World()
}

extension TTS {
  struct World {
    var isSpeaking =  Engine.default.isSpeaking
    var isSpeakingPublisher = Engine.default.$isSpeaking
    var speakingProgressPublisher = Engine.default.$speakingProgress
    var setRateRatio = { Engine.default.rateRatio = $0 }
    var speech = { Engine.default.speech(date: $0) }
    var time = { Engine.default.time(date: $0) }
  }
}

var Current = World()
