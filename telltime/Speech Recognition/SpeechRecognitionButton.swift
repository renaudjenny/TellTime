import SwiftUI
import Combine

struct SpeechRecognitionButton: View {
    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>

    var body: some View {
        Button(action: onTapped) {
            image
                .resizable()
                .accentColor(.white)
                .padding(4)
                .background(Color.red)
                .cornerRadius(8)
                .animation(nil)
                .opacity(isRecording ? 0.8 : 1)
                .animation(isRecording ? glowingAnimation : .default)
                .frame(width: 50, height: 50)
        }
        .padding()
        .accessibilityLabel(label)
        .onAppear(perform: subscribeToSpeechRecognitionStatus)
    }

    private func onTapped() {
        store.send(.speechRecognition(.buttonTapped))
    }

    private func subscribeToSpeechRecognitionStatus() {
        store.send(.speechRecognition(.subscribeToSpeechRecognitionStatus))
    }

    private var image: Image {
        switch store.state.speechRecognition.status {
        case .notStarted, .stopped: return Image(systemName: "waveform.circle")
        case .recording: return Image(systemName: "record.circle")
        case .stopping: return Image(systemName: "stop.circle")
        }
    }

    private var label: Text {
        switch store.state.speechRecognition.status {
        case .notStarted, .stopped: return Text("Speech Recognition ready")
        case .recording: return Text("Speech Recognition recording...")
        case .stopping: return Text("Speech Recognition stopping...")
        }
    }

    private var isRecording: Bool {
        store.state.speechRecognition.status == .recording
    }

    private var glowingAnimation: Animation {
        Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
    }
}

#if DEBUG
struct SpeechRecognitionButton_Previews: PreviewProvider {
    static var previews: some View {
        SpeechRecognitionButton()
            .environmentObject(previewStore { _ in })
    }
}

#endif
