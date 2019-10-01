import AVFoundation
import SwiftPastTen
import Combine

struct TTS {
  var tellTimeEngine: TellTimeEngine = SwiftPastTen()

  let hour: Int
  let minute: Int

  var digitalTime: String {
    let minute = self.minute > 9 ? "\(self.minute)" : "0\(self.minute)"
    let hour = self.hour > 9 ? "\(self.hour)" : "0\(self.hour)"
    return "\(hour):\(minute)"
  }

  func speech(text: String) {
    let tellTimeText = try? self.tellTimeEngine.tell(time: text)
    let speechSynthesizer = AVSpeechSynthesizer()
    let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: tellTimeText ?? text)
    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
    speechSynthesizer.speak(speechUtterance)
  }

  func speechTime() {
    self.speech(text: self.digitalTime)
  }
}
