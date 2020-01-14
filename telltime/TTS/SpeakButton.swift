import SwiftUI

struct SpeakButtonContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>

  var body: some View {
    SpeakButton(
      isSpeaking: self.store.state.tts.isSpeaking,
      speakingProgress: self.store.state.tts.speakingProgress,
      tellTime: self.tellTime
    )
      .onAppear(perform: self.subscribeToTTSEngine)
  }

  private func tellTime() {
    self.store.send(.tts(.tellTime(self.store.state.clock.date)))
  }

  private func subscribeToTTSEngine() {
    self.store.send(App.SideEffect.tts(.subscribeToEngineIsSpeaking))
    self.store.send(App.SideEffect.tts(.subscribeToEngineSpeakingProgress))
  }
}

struct SpeakButton: View {
  let isSpeaking: Bool
  let speakingProgress: Double
  let tellTime: () -> Void

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        Rectangle()
          .fill(Color.gray)
          .cornerRadius(8)
        Rectangle()
          .size(
            width: geometry.size.width * self.widthProgressRatio,
            height: geometry.size.height)
          .fill(Color.red)
          .cornerRadius(8)
          .animationIfEnabled(.easeInOut)
      }
      Button(action: self.tellTime) {
        Image(systemName: "speaker.2")
          .padding()
          .accentColor(.white)
          .cornerRadius(8)
      }
      .disabled(self.isSpeaking)
      .layoutPriority(1)
    }
  }

  private var widthProgressRatio: CGFloat {
    self.isSpeaking ? CGFloat(self.speakingProgress) : 1.0
  }
}

#if DEBUG
struct SpeakButton_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SpeakButton(isSpeaking: false, speakingProgress: 1, tellTime: {})
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Speak Button not speaking, 100% progress")
      SpeakButton(isSpeaking: true, speakingProgress: 1/4, tellTime: {})
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Speak Button speaking, 25% progress")
      SpeakButton(isSpeaking: true, speakingProgress: 1/2, tellTime: {})
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Speak Button speaking, 50% progress")
      SpeakButton(isSpeaking: true, speakingProgress: 3/4, tellTime: {})
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Speak Button speaking, 75% progress")
      SpeakButton(isSpeaking: true, speakingProgress: 9/10, tellTime: {})
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Speak Button speaking, 90% progress")
      SpeakButton(isSpeaking: true, speakingProgress: 1, tellTime: {})
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Speak Button speaking, 100% progress")
    }
  }
}
#endif
