import ComposableArchitecture
import Speech
import SwiftSpeechRecognizerDependency

struct SpeechRecognizer: ReducerProtocol {
    struct State: Equatable {
        var status: SpeechRecognitionStatus = .notStarted
        var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
        var utterance: String?
    }

    enum Action: Equatable {
        case buttonTapped
        case startRecording
        case stopRecording
        case setStatus(SpeechRecognitionStatus)
        case setUtterance(String?)
        case requestAuthorization
        case setAuthorizationStatus(SFSpeechRecognizerAuthorizationStatus)
        case setRecognizedDate(Date)
    }

    struct RecognitionStatusId: Hashable { }
    struct NewUtteranceId: Hashable { }
    struct AuthorizationStatusId: Hashable { }
    struct RecognizedTimeDebounceId: Hashable { }

    @Dependency(\.speechRecognizer) var speechRecognizer

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .buttonTapped:
            switch state.status {
            case .recording, .stopping:
                return stopRecording(state: &state)
            case .notStarted, .stopped:
                return startRecording(state: &state)
            }
        case .startRecording:
return stopRecording(state: &state)
        case .stopRecording:
            speechRecognizer.stopRecording()
            return .cancel(id: RecognizedTimeDebounceId())
        case .setStatus(let status):
            state.status = status
            switch status {
            case .recording:
                state.utterance = nil
            case .stopped:
                state.utterance = nil
                return .merge(
                    .cancel(id: NewUtteranceId()),
                    .cancel(id: RecognitionStatusId())
                )
            default: break
            }
            return .none
        case let .setUtterance(utterance):
            state.utterance = utterance
//            if
//                let utterance = utterance,
//                let recognizedTime = environment.recognizeTime(utterance, environment.calendar) {
//                return Effect(value: .setRecognizedDate(recognizedTime))
//                    .debounce(id: RecognizedTimeDebounceId(), for: .seconds(1), scheduler: environment.mainQueue)
//            }
            return .none
        case .setAuthorizationStatus(let authorizationStatus):
            state.authorizationStatus = authorizationStatus
            switch authorizationStatus {
            case .authorized:
                return .merge(
                    startRecording(state: &state),
                    .cancel(id: AuthorizationStatusId())
                )
            case .notDetermined:
                return .merge(
                    requestAuthorization(state: &state),
                    .cancel(id: AuthorizationStatusId())
                )
            default: break
            }
            return .cancel(id: AuthorizationStatusId())
        case .requestAuthorization:
            return requestAuthorization(state: &state)
        case .setRecognizedDate:
            return stopRecording(state: &state)
        }
    }

    private func startRecording(state: inout State) -> EffectTask<Action> {
        guard state.authorizationStatus == .authorized
        else { return .task { .requestAuthorization } }
        do {
            try speechRecognizer.startRecording()
            return .merge(
                .run(operation: { send in
                    for await recognitionStatus in speechRecognizer.recognitionStatus() {
                        await send(.setStatus(recognitionStatus))
                    }
                })
                .cancellable(id: RecognitionStatusId()),
                .run(operation: { send in
                    for await newUtterance in speechRecognizer.newUtterance() {
                        await send(.setUtterance(newUtterance))
                    }
                })
                .cancellable(id: NewUtteranceId())
            )
        } catch {
            return stopRecording(state: &state)
        }
    }

    private func stopRecording(state: inout State) -> EffectTask<Action> {
        speechRecognizer.stopRecording()
        return .cancel(id: RecognizedTimeDebounceId())
    }

    private func requestAuthorization(state: inout State) -> EffectTask<Action> {
        speechRecognizer.requestAuthorization()
        return .run { send in
            for await authorizationStatus in speechRecognizer.authorizationStatus() {
                await send(.setAuthorizationStatus(authorizationStatus))
            }
        }
    }
}
