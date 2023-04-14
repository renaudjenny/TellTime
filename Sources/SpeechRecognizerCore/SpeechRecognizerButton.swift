import ComposableArchitecture
import SwiftSpeechRecognizerDependency
import SwiftUI

public struct SpeechRecognizerButton: View {
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

    public init(store: StoreOf<SpeechRecognizer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            Button { viewStore.send(.buttonTapped) } label: {
                viewStore.image
                    .resizable()
                    .accentColor(.white)
                    .padding(4)
                    .background(Color.red)
                    .cornerRadius(8)
                    .opacity(viewStore.isRecording ? 0.8 : 1)
                    .frame(width: 50, height: 50)
            }
            .accessibilityLabel(viewStore.label)
        }
    }
}

#if DEBUG
import Speech
import SwiftSpeechRecognizer

public struct SpeechRecognizerButton_Previews: PreviewProvider {
    public static var previews: some View {
        Preview(store: .preview)
    }

    private struct Preview: View {
        let store: StoreOf<SpeechRecognizer>

        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack {
                    Text("Hi")
                    SpeechRecognizerButton(store: store)
                    Text(viewStore.utterance ?? "").multilineTextAlignment(.center)
                    Text("Speech status: \(viewStore.status.previewDescription)")
                    Text("Authorization status: \(viewStore.authorizationStatus.previewDescription)")
                }
                .padding()
            }
        }
    }
}

public extension Store where State == SpeechRecognizer.State, Action == SpeechRecognizer.Action {
    static var preview: Store<SpeechRecognizer.State, SpeechRecognizer.Action> {
        Store(initialState: SpeechRecognizer.State(), reducer: SpeechRecognizer())
    }
}

extension SpeechRecognitionStatus {
    var previewDescription: String {
        switch self {
        case .notStarted: return "not started"
        case .recording: return "recording"
        case .stopping: return "stopping"
        case .stopped: return "stopped"
        }
    }
}

extension SFSpeechRecognizerAuthorizationStatus {
    var previewDescription: String {
        switch self {
        case .notDetermined: return "not determined"
        case .denied: return "denied"
        case .restricted: return "restricted"
        case .authorized: return "authorized"
        @unknown default: return "unknown!"
        }
    }
}
#endif
