import SwiftUI
import ComposableArchitecture
import TTSCore

struct Buttons: View {
    struct ViewState: Equatable { }

    enum ViewAction: Equatable {
        case presentAbout
        case presentConfiguration
        case setRandomDate
    }

    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store.scope(state: { $0.view }, action: AppAction.view)) { viewStore in
            HStack {
                SpeakButton(store: store.scope(state: \.tts, action: AppAction.tts))
                Spacer()
                Button { viewStore.send(.setRandomDate) } label: {
                    Image(systemName: "shuffle")
                        .padding()
                        .accentColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                Spacer()
                Button { viewStore.send(.presentConfiguration) } label: {
                    Image(systemName: "gear")
                        .padding()
                        .accentColor(.red)
                }
                Spacer()
                Button { viewStore.send(.presentAbout) } label: {
                    Image(systemName: "questionmark.circle")
                        .padding()
                        .accentColor(.red)
                }
            }
            .frame(maxWidth: 800)
            .padding([.horizontal, .top])
        }
    }
}

private extension AppState {
    var view: Buttons.ViewState {
        Buttons.ViewState()
    }
}

private extension AppAction {
    static func view(localAction: Buttons.ViewAction) -> Self {
        switch localAction {
        case .presentAbout: return .presentAbout
        case .presentConfiguration: return .configuration(.present)
        case .setRandomDate: return .setRandomDate
        }
    }
}
