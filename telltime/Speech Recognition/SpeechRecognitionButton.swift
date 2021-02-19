import SwiftUI
import ComposableArchitecture
import Speech
import SwiftSpeechCombine

struct SpeechRecognitionButton: View {
    struct ViewState: Equatable {
        var status: SpeechRecognitionStatus
    }

    enum ViewAction: Equatable {
        case buttonTapped
    }

    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store.scope(state: { $0.view }, action: AppAction.view)) { viewStore in
            Button { viewStore.send(.buttonTapped) } label: {
                image(viewStore: viewStore)
                    .resizable()
                    .accentColor(.white)
                    .padding(4)
                    .background(Color.red)
                    .cornerRadius(8)
                    .opacity(isRecording(viewStore: viewStore) ? 0.8 : 1)
                    .animation(isRecording(viewStore: viewStore) ? glowingAnimation : .default, value: viewStore.status)
                    .frame(width: 50, height: 50)
            }
            .padding()
            .accessibilityLabel(label(viewStore: viewStore))
        }
    }

    private func image(viewStore: ViewStore<ViewState, ViewAction>) -> Image {
        switch viewStore.status {
        case .notStarted, .stopped: return Image(systemName: "waveform.circle")
        case .recording: return Image(systemName: "record.circle")
        case .stopping: return Image(systemName: "stop.circle")
        }
    }

    private func label(viewStore: ViewStore<ViewState, ViewAction>) -> Text {
        switch viewStore.status {
        case .notStarted, .stopped: return Text("Speech Recognition ready")
        case .recording: return Text("Speech Recognition recording...")
        case .stopping: return Text("Speech Recognition stopping...")
        }
    }

    private func isRecording(viewStore: ViewStore<ViewState, ViewAction>) -> Bool {
        viewStore.status == .recording
    }

    private var glowingAnimation: Animation {
        Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
    }
}

private extension AppState {
    var view: SpeechRecognitionButton.ViewState {
        SpeechRecognitionButton.ViewState(status: speechRecognition.status)
    }
}

private extension AppAction {
    static func view(localAction: SpeechRecognitionButton.ViewAction) -> Self {
        switch localAction {
        case .buttonTapped: return .speechRecognition(.buttonTapped)
        }
    }
}

#if DEBUG
struct SpeechRecognitionButton_Previews: PreviewProvider {
    static var previews: some View {
        SpeechRecognitionButton(store: .preview)
    }
}

#endif
