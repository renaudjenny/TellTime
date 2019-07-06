import SwiftUI
import AVFoundation
import SwiftPastTen

struct TTS: View {
  @EnvironmentObject var store: Store
  var tellTimeEngine: TellTimeEngine = SwiftPastTen()

  var digitalTime: String {
    let minute = self.store.minute > 9 ? "\(self.store.minute)" : "0\(self.store.minute)"
    return "\(self.store.hour):\(minute)"
  }

  var body: some View {
    speach(text: self.digitalTime)
    return Text(self.digitalTime)
  }

  private func speach(text: String) {
    let tellTimeText = try? self.tellTimeEngine.tell(time: text)
    let speechSynthesizer = AVSpeechSynthesizer()
    let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: tellTimeText ?? text)
    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
    speechSynthesizer.speak(speechUtterance)
  }
}
