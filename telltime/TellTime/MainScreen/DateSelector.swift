import ComposableArchitecture
import SpeechRecognizerCore
import SwiftUI

struct DateSelector: View {
    struct ViewState: Equatable {
        var date: Date
        var recognizedUtterance: String?
    }

    enum ViewAction: Equatable {
        case setDate(Date)
    }

    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store.scope(state: { $0.view }, action: AppAction.view)) { viewStore in
            VStack {
                ZStack {
                    HStack {
                        SpeechRecognizerButton(store: store.scope(
                            state: \.speechRecognizer,
                            action: AppAction.speechRecognizer
                        ))
                        Spacer()
                    }

                    DatePicker(
                        selection: viewStore.binding(get: \.date, send: ViewAction.setDate),
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

private extension AppState {
    var view: DateSelector.ViewState {
        DateSelector.ViewState(
            date: date,
            recognizedUtterance: speechRecognizer.utterance
        )
    }
}

private extension AppAction {
    static func view(localAction: DateSelector.ViewAction) -> Self {
        switch localAction {
        case .setDate(let date): return .setDate(date)
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
            .previewLayout(.iPhoneSe(.landscape))
        }
    }
}

#endif
