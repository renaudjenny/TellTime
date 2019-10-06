import AVFoundation
import SwiftPastTen
import Combine

struct TTS {
  var tellTimeEngine: TellTimeEngine = SwiftPastTen()

  let hour: Int
  let minute: Int

  func speech(text: String) {
    let tellTimeText = try? self.tellTimeEngine.tell(time: text)
    let speechSynthesizer = AVSpeechSynthesizer()
    let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: tellTimeText ?? text)
    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
    speechSynthesizer.speak(speechUtterance)
  }

  func speechTime() {
    self.speech(text: DigitalTime.from(hour: self.hour, minute: self.minute))
  }
}
