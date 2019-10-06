import AVFoundation
import SwiftPastTen
import Combine

final class TTS: NSObject, AVSpeechSynthesizerDelegate {
  var tellTimeEngine: TellTimeEngine = SwiftPastTen()

  var isSpeaking = PassthroughSubject<Bool, Never>()
  let speechSynthesizer = AVSpeechSynthesizer()

  override init() {
    super.init()
    self.speechSynthesizer.delegate = self
  }

  func speech(text: String) {
    let tellTimeText = try? self.tellTimeEngine.tell(time: text)
    let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: tellTimeText ?? text)
    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
    self.speechSynthesizer.speak(speechUtterance)
    self.isSpeaking.send(true)
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didFinish utterance: AVSpeechUtterance
  ) {
    self.isSpeaking.send(false)
  }
}
