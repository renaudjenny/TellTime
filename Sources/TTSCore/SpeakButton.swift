import SwiftUI
import ComposableArchitecture

public struct SpeakButton: View {
    struct ViewState: Equatable {
        var isSpeaking: Bool
        var widthProgressRatio: CGFloat

        init(_ state: TTS.State) {
            self.isSpeaking = state.isSpeaking
            self.widthProgressRatio = state.speakingProgress
        }
    }

    let store: StoreOf<TTS>
    @ObservedObject private var viewStore: ViewStore<ViewState, TTS.Action>

    public init(store: StoreOf<TTS>) {
        self.store = store
        _viewStore = ObservedObject(
            initialValue: ViewStore(store.scope(state: ViewState.init))
        )
    }

    public var body: some View {
        Button { viewStore.send(.speak) } label: {
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

#if DEBUG
struct SpeakButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SpeakButton(store: .preview)
            SpeakButton(store: .preview(modifyState: {
                $0.speakingProgress = 1/4
                $0.isSpeaking = true
            }))
            SpeakButton(store: .preview(modifyState: {
                $0.speakingProgress = 1/2
                $0.isSpeaking = true
            }))
            SpeakButton(store: .preview(modifyState: {
                $0.speakingProgress = 3/4
                $0.isSpeaking = true
            }))
            SpeakButton(store: .preview(modifyState: {
                $0.speakingProgress = 9/10
                $0.isSpeaking = true
            }))
            SpeakButton(store: .preview(modifyState: {
                $0.speakingProgress = 1
                $0.isSpeaking = true
            }))
        }
    }
}

extension Store where State == TTS.State, Action == TTS.Action {
    static func preview(modifyState: (inout TTS.State) -> Void) -> Store<TTS.State, TTS.Action> {
        var state = TTS.State()
        modifyState(&state)
        return Store(initialState: state, reducer: TTS())
    }
    static var preview: Store<TTS.State, TTS.Action> { preview(modifyState: { _ in }) }
}
#endif
