import SwiftUI

struct SpeakButton: View {
    @EnvironmentObject var store: Store<App.State, App.Action>

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
                    .animation(.easeInOut)
            }
            Button(action: tellTime) {
                Image(systemName: "speaker.2")
                    .padding()
                    .accentColor(.white)
                    .cornerRadius(8)
            }
            .disabled(store.state.tts.isSpeaking)
            .layoutPriority(1)
        }
        .onAppear(perform: self.subscribeToTTSEngine)
    }

    private var widthProgressRatio: CGFloat {
        return store.state.tts.isSpeaking ? CGFloat(store.state.tts.speakingProgress) : 1.0
    }

    private func tellTime() {
        self.store.send(.tts(.tellTime(self.store.state.date)))
    }

    private func subscribeToTTSEngine() {
        self.store.send(TTS.subscribeToEngineIsSpeaking())
        self.store.send(TTS.subscribeToEngineSpeakingProgress())
    }
}

#if DEBUG
struct SpeakButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      SpeakButton()
        .environmentObject(App.previewStore)
      SpeakButton()
        .environmentObject(App.previewStore {
            $0.tts.speakingProgress = 1/4
            $0.tts.isSpeaking = true
        })
      SpeakButton()
        .environmentObject(App.previewStore {
            $0.tts.speakingProgress = 1/2
            $0.tts.isSpeaking = true
        })
      SpeakButton()
        .environmentObject(App.previewStore {
            $0.tts.speakingProgress = 3/4
            $0.tts.isSpeaking = true
        })
      SpeakButton()
        .environmentObject(App.previewStore {
            $0.tts.speakingProgress = 9/10
            $0.tts.isSpeaking = true
        })
      SpeakButton()
        .environmentObject(App.previewStore {
            $0.tts.speakingProgress = 1
            $0.tts.isSpeaking = true
        })
    }
  }
}
#endif
