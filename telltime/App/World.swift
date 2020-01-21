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
  var clockFaceShownTimeInterval: TimeInterval = 2
  var deviceOrientation = UIDevice.current.orientation
  var orientationDidChangePublisher = NotificationCenter.default
    .publisher(for: UIDevice.orientationDidChangeNotification)

  var isAnimationDisabled = false

  var tts = TTS.World()
  var clock = Clock.World()
}

extension TTS {
  struct World {
    var isSpeaking =  Engine.default.isSpeaking
    var isSpeakingPublisher = Engine.default.$isSpeaking.eraseToAnyPublisher()
    var speakingProgressPublisher = Engine.default.$speakingProgress.eraseToAnyPublisher()
    var setRateRatio = { Engine.default.rateRatio = $0 }
    var speech = { Engine.default.speech(date: $0) }
    var time = { Engine.default.time(date: $0) }
  }
}

extension Clock {
  struct World {
    var randomControlRatio = (
      leftX: { CGFloat.random(in: 0.1...1) },
      leftY: { CGFloat.random(in: 0.1...1) },
      rightX: { CGFloat.random(in: 0.1...1) },
      rightY: { CGFloat.random(in: 0.1...1) }
    )

    var randomBorderMarginRatio = (
      maxMargin: { CGFloat.random(in: 0...$0) },
      angleMargin: { Double.random(in: 0...1/3) }
    )

    private static let angles: [Angle] = [.zero, .degrees(-5), .degrees(5)]
    var randomAngle: () -> Angle? = Self.angles.randomElement
    private static let scales: [CGFloat] = [1, 1.1, 0.9]
    var randomScale: () -> CGFloat? = Self.scales.randomElement
  }
}

var Current = World()
