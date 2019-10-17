import AVFoundation
import SwiftPastTen
import Combine

final class TTS: NSObject, AVSpeechSynthesizerDelegate {
  var tellTimeEngine: TellTimeEngine = SwiftPastTen()

  var isSpeaking = PassthroughSubject<Bool, Never>()
  var speakingProgress = PassthroughSubject<Double, Never>()
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
    didStart utterance: AVSpeechUtterance
  ) {
    self.speakingProgress.send(0.0)
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didFinish utterance: AVSpeechUtterance
  ) {
    self.isSpeaking.send(false)
    self.speakingProgress.send(1.0)
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    willSpeakRangeOfSpeechString characterRange: NSRange,
    utterance: AVSpeechUtterance
  ) {
    let total = Double(utterance.speechString.count)
    let averageBound = [Double(characterRange.lowerBound), Double(characterRange.upperBound)]
      .reduce(0, +)/2
    self.speakingProgress.send(averageBound/total)
  }
}
