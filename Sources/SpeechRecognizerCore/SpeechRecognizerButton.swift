import ComposableArchitecture
import Speech
import SwiftUI
import SwiftSpeechRecognizerDependency

struct SpeechRecognizerButton: View {
    struct ViewState: Equatable {
        var isRecording: Bool
        var label: Text
        var image: Image

        init(_ state: SpeechRecognizer.State) {
            switch state.status {
            case .notStarted, .stopped:
                self.label = Text("Speech Recognition ready")
                self.isRecording = false
                self.image = Image(systemName: "waveform.circle")
            case .recording:
                self.label = Text("Speech Recognition recording...")
                self.isRecording = true
                self.image = Image(systemName: "record.circle")
            case .stopping:
                self.label = Text("Speech Recognition stopping...")
                self.isRecording = false
                self.image = Image(systemName: "stop.circle")
            }
            self.isRecording = state.status == .recording

        }
    }

    let store: StoreOf<SpeechRecognizer>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            Button { viewStore.send(.buttonTapped) } label: {
                viewStore.image
                    .resizable()
                    .accentColor(.white)
                    .padding(4)
                    .background(Color.red)
                    .cornerRadius(8)
                    .opacity(viewStore.isRecording ? 0.8 : 1)
                    .animation(viewStore.isRecording ? glowingAnimation : .default, value: viewStore.state)
                    .frame(width: 50, height: 50)
            }
            .accessibilityLabel(viewStore.label)
        }
    }

    private var glowingAnimation: Animation {
        Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
    }
}
//
//#if DEBUG
//struct SpeechRecognitionButton_Previews: PreviewProvider {
//    static var previews: some View {
//        SpeechRecognitionButton(store: .preview)
//    }
//}
//#endif
