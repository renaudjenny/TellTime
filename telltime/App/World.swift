import SwiftUI
import Combine

// For more information check "How To Control The World" - Stephen Celis
// https://vimeo.com/291588126

struct World {
  var date = { Date() }
  var calendar = Calendar.autoupdatingCurrent
  var deviceOrientation = UIDevice.current.orientation
  var orientationDidChangePublisher = NotificationCenter.default
    .publisher(for: UIDevice.orientationDidChangeNotification)

  var tts = TTS.World()
}

var Current = World()
