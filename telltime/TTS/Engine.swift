import AVFoundation
import SwiftPastTen
import Combine

protocol TTSEngine: class {
    var rateRatio: Float { get set }
    func speech(date: Date)
}

extension TTS {
  final class Engine: NSObject, TTSEngine, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var speakingProgress: Double = 0.0

    var rateRatio: Float = 1.0
    private let speechSynthesizer = AVSpeechSynthesizer()

    let tellTime: (Date, Calendar) -> String
    let calendar: Calendar

    init(
        tellTime: @escaping (Date, Calendar) -> String,
        calendar: Calendar
    ) {
        self.tellTime = tellTime
        self.calendar = calendar
        super.init()
        self.speechSynthesizer.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }

    func speech(date: Date) {
      let tellTimeText = tellTime(date, calendar)
      let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: tellTimeText)
      speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
      speechUtterance.rate *= self.rateRatio
      self.speechSynthesizer.speak(speechUtterance)
      self.isSpeaking = true
    }

    func speechSynthesizer(
      _ synthesizer: AVSpeechSynthesizer,
      didStart utterance: AVSpeechUtterance
    ) {
      self.speakingProgress = 0.0
    }

    func speechSynthesizer(
      _ synthesizer: AVSpeechSynthesizer,
      didFinish utterance: AVSpeechUtterance
    ) {
      self.isSpeaking = false
      self.speakingProgress = 1.0
    }

    func speechSynthesizer(
      _ synthesizer: AVSpeechSynthesizer,
      willSpeakRangeOfSpeechString characterRange: NSRange,
      utterance: AVSpeechUtterance
    ) {
      let total = Double(utterance.speechString.count)
      let averageBound = [Double(characterRange.lowerBound), Double(characterRange.upperBound)]
        .reduce(0, +)/2
      self.speakingProgress = averageBound/total
    }
  }
}
