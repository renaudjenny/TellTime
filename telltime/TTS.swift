import SwiftUI
import AVFoundation

struct TTS: View {
  @EnvironmentObject var store: Store

  var digitalTime: String {
    let minute = self.store.minute > 9 ? "\(self.store.minute)" : "0\(self.store.minute)"
    return "\(self.store.hour):\(minute)"
  }

  var body: some View {
    speach(text: self.digitalTime)
    return Text(self.digitalTime)
  }

  private func speach(text: String) {
    let speechSynthesizer = AVSpeechSynthesizer()
    let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: text)
    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
    speechSynthesizer.speak(speechUtterance)
  }
}
