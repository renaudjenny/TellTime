import SwiftUI
import ComposableArchitecture
import TTSCore

struct Buttons: View {
    let store: StoreOf<App>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            HStack {
                SpeakButton(store: store.scope(state: \.tts, action: App.Action.tts))
                Spacer()
                Button { viewStore.send(.setRandomDate) } label: {
                    Image(systemName: "shuffle")
                        .padding()
                        .accentColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                Spacer()
                Button { viewStore.send(.configuration(.present)) } label: {
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
