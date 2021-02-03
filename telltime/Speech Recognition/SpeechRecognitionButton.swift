import SwiftUI
import Combine

struct SpeechRecognitionButton: View {
    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>

    var body: some View {
        Button(action: onTapped) {
            image
                .padding()
                .accentColor(.white)
                .background(Color.red)
                .cornerRadius(8)
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
        case .notStarted, .stopped: return Image(systemName: "mouth.fill")
        case .recording: return Image(systemName: "waveform")
        case .stopping: return Image(systemName: "stop")
        }
    }

    private var label: Text {
        switch store.state.speechRecognition.status {
        case .notStarted, .stopped: return Text("Speech Recognition ready")
        case .recording: return Text("Speech Recognition recording...")
        case .stopping: return Text("Speech Recognition stopping...")
        }
    }
}
