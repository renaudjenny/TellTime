import SwiftUI
import ComposableArchitecture

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
                HStack {
                    SpeechRecognitionButton()

                    DatePicker(
                        selection: viewStore.binding(get: \.date, send: ViewAction.setDate),
                        displayedComponents: [.hourAndMinute]
                    ) {
                        Text("Select a time")
                    }
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    .padding()
                }
                viewStore.recognizedUtterance.map { recognizedUtterance in
                    Text(recognizedUtterance)
                }
            }
        }
    }
}

private extension AppState {
    var view: DateSelector.ViewState {
        return DateSelector.ViewState(
            date: date,
            recognizedUtterance: speechRecognition.utterance
        )
    }
}

private extension AppAction {
    static func view(localAction: DateSelector.ViewAction) -> Self {
        switch localAction {
        case .setDate(let date): return .changeDate(date)
        }
    }
}
