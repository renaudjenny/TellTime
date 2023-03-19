import SwiftUI
import ComposableArchitecture

struct SpeakButton: View {
    struct ViewState: Equatable {
        var date: Date
        var isSpeaking: Bool
        var widthProgressRatio: CGFloat
    }

    enum ViewAction {
        case tellTime(Date)
    }

    let store: Store<AppState, AppAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, ViewAction>

    init(store: Store<AppState, AppAction>) {
        self.store = store
        _viewStore = ObservedObject(
            initialValue: ViewStore(store.scope(state: { $0.view }, action: AppAction.view))
        )
    }

    var body: some View {
        Button { viewStore.send(.tellTime(viewStore.date)) } label: {
            Image(systemName: "speaker.2")
                .padding()
                .accentColor(.white)
                .cornerRadius(8)
        }
        .disabled(viewStore.isSpeaking)
        .background(GeometryReader { geometry in
            Rectangle()
                .fill(Color.gray)
                .cornerRadius(8)
            Rectangle()
                .size(
                    width: geometry.size.width * viewStore.widthProgressRatio,
                    height: geometry.size.height
                )
                .fill(Color.red)
                .cornerRadius(8)
                .animation(.easeInOut, value: viewStore.widthProgressRatio)
        })
    }
}

private extension AppState {
    var view: SpeakButton.ViewState {
        SpeakButton.ViewState(
            date: date,
            isSpeaking: tts.isSpeaking,
            widthProgressRatio: tts.isSpeaking ? CGFloat(tts.speakingProgress) : 1.0
        )
    }
}

private extension AppAction {
    static func view(localAction: SpeakButton.ViewAction) -> Self {
        switch localAction {
        case .tellTime(let date): return .tts(.tellTime(date))
        }
    }
}

#if DEBUG
struct SpeakButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SpeakButton(store: .preview)
            SpeakButton(store: .preview(modifyState: {
                $0.tts.speakingProgress = 1/4
                $0.tts.isSpeaking = true
            }))
            SpeakButton(store: .preview(modifyState: {
                $0.tts.speakingProgress = 1/2
                $0.tts.isSpeaking = true
            }))
            SpeakButton(store: .preview(modifyState: {
                $0.tts.speakingProgress = 3/4
                $0.tts.isSpeaking = true
            }))
            SpeakButton(store: .preview(modifyState: {
                $0.tts.speakingProgress = 9/10
                $0.tts.isSpeaking = true
            }))
            SpeakButton(store: .preview(modifyState: {
                $0.tts.speakingProgress = 1
                $0.tts.isSpeaking = true
            }))
        }
    }
}
#endif
