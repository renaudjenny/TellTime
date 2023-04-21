import ComposableArchitecture
import SpeechRecognizerCore
import SwiftUI

struct DateSelector: View {
    struct ViewState: Equatable {
        var date: Date
        var recognizedUtterance: String?

        init(_ state: App.State) {
            date = state.date
            recognizedUtterance = state.speechRecognizer.utterance
        }
    }

    let store: StoreOf<App>

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            VStack {
                ZStack {
                    HStack {
                        SpeechRecognizerButton(store: store.scope(
                            state: \.speechRecognizer,
                            action: App.Action.speechRecognizer
                        ))
                        Spacer()
                    }

                    DatePicker(
                        selection: viewStore.binding(get: \.date, send: App.Action.setDate),
                        displayedComponents: [.hourAndMinute]
                    ) {
                        Text("Select a time")
                    }
                    .labelsHidden()
                    .padding()

                    Spacer()
                }
                viewStore.recognizedUtterance.map { recognizedUtterance in
                    Text(recognizedUtterance)
                }
            }
            .frame(maxWidth: 800)
            .padding(.horizontal)
        }
    }
}

#if DEBUG
struct DateSelector_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DateSelector(store: .preview)
            VStack {
                DateSelector(store: .preview)
                Buttons(store: .preview)
            }
        }
    }
}
#endif
