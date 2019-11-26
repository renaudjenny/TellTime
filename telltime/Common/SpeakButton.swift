import SwiftUI

struct SpeakButtonContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  private var speakingProgress: Binding<Double> { .init(
    get: { self.store.state.tts.engine.speakingProgress },
    set: { _ in }
  )}

  var body: some View {
    SpeakButton(
      isSpeaking: self.store.state.tts.engine.isSpeaking,
      //speakingProgress: self.store.state.tts.engine.speakingProgress,
      speakingProgress: self.speakingProgress,
      tellTime: self.tellTime
    )
  }

  private func tellTime() {
    self.store.state.tts.engine.speech(date: self.store.state.clock.date)
  }
}

struct SpeakButton: View {
  let isSpeaking: Bool
  @Binding var speakingProgress: Double
  let tellTime: () -> Void

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        Rectangle()
          .fill(Color.gray)
          .cornerRadius(8)
        Rectangle()
          .size(
            width: geometry.size.width * CGFloat(self.speakingProgress),
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
      .disabled(self.isSpeaking)
      .layoutPriority(1)
    }
  }
}
