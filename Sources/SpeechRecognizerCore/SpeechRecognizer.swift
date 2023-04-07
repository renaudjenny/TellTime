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
        case cancel
    }

    @Dependency(\.speechRecognizer) var speechRecognizer

    public init() {}

    private enum AuthorizationStatusTaskID {}
    private enum RecognitionStatusTaskID {}
    private enum NewUtteranceTaskID {}

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
            return startRecording(state: &state)
        case .stopRecording:
            return stopRecording(state: &state)
        case let .setStatus(status):
            state.status = status
            switch status {
            case .recording, .stopping:
                state.utterance = nil
            case .notStarted, .stopped:
                break
            }
            return .none
        case let .setUtterance(utterance):
            state.utterance = utterance
            return .none
        case let .setAuthorizationStatus(authorizationStatus):
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
        case .cancel:
            return .cancel(ids: [AuthorizationStatusTaskID.self, RecognitionStatusTaskID.self, NewUtteranceTaskID.self])
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
                .cancellable(id: RecognitionStatusTaskID.self),
                .run(operation: { send in
                    for await newUtterance in speechRecognizer.newUtterance() {
                        await send(.setUtterance(newUtterance))
                    }
                })
                .cancellable(id: NewUtteranceTaskID.self)
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
        .cancellable(id: AuthorizationStatusTaskID.self)
    }
}
