import SwiftUI

struct SpeakButton: View {
  @EnvironmentObject var tts: TTS
  @EnvironmentObject var clock: ClockStore

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        Rectangle()
          .fill(Color.gray)
          .cornerRadius(8)
        Rectangle()
          .size(
            width: geometry.size.width * CGFloat(self.tts.speakingProgress),
            height: geometry.size.height)
          .fill(Color.red)
          .cornerRadius(8)
          .animation(.easeInOut)
      }
      Button(action: self.tellTime) {
        Image(systemName: "speaker.2")
          .padding()
          .accentColor(.white)
          .cornerRadius(8)
          .animation(.easeInOut)
      }
      .disabled(self.tts.isSpeaking)
      .layoutPriority(1)
    }
  }

  private func tellTime() {
    self.tts.speech(date: self.clock.date)
  }
}
