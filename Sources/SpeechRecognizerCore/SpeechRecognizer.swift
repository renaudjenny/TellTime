import ComposableArchitecture
import Speech
import SwiftSpeechRecognizerDependency

public struct SpeechRecognizer: ReducerProtocol {
    public struct State: Equatable {
        public var status: SpeechRecognitionStatus = .notStarted
        public var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
        public var utterance: String?

        public init(
            status: SpeechRecognitionStatus = .notStarted,
            authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined,
            utterance: String? = nil
        ) {
            self.status = status
            self.authorizationStatus = authorizationStatus
            self.utterance = utterance
        }
    }

    public enum Action: Equatable {
        case buttonTapped
        case startRecording
        case stopRecording
        case setStatus(SpeechRecognitionStatus)
        case setUtterance(String?)
        case requestAuthorization
        case setAuthorizationStatus(SFSpeechRecognizerAuthorizationStatus)
    }

    struct RecognizerStatusId: Hashable { }
    struct NewUtteranceId: Hashable { }

    @Dependency(\.speechRecognizer) var speechRecognizer

    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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
            return stopRecording(state: &state)
        case .setStatus(let status):
            state.status = status
            switch status {
            case .recording:
                state.utterance = nil
            case .stopped:
                state.utterance = nil
                return .cancel(id: NewUtteranceId())
            default: break
            }
            return .none
        case let .setUtterance(utterance):
            state.utterance = utterance
            return .none
        case .setAuthorizationStatus(let authorizationStatus):
            state.authorizationStatus = authorizationStatus
            switch authorizationStatus {
            case .authorized:
                return startRecording(state: &state)
            case .notDetermined:
                return requestAuthorization(state: &state)
            default: break
            }
            return .none
        case .requestAuthorization:
            return requestAuthorization(state: &state)
        }
    }

    private func startRecording(state: inout State) -> EffectTask<Action> {
        guard state.authorizationStatus == .authorized
        else { return requestAuthorization(state: &state) }
        do {
            try speechRecognizer.startRecording()
            return .merge(
                .run(operation: { send in
                    for await recognitionStatus in speechRecognizer.recognitionStatus() {
                        await send(.setStatus(recognitionStatus))
                    }
                })
                .cancellable(id: RecognizerStatusId()),
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
        return .none
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
