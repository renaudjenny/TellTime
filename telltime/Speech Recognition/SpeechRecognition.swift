import SwiftUI
import Combine
import Speech

struct SpeechRecognitionState {
    var status: SpeechRecognitionStatus = .notStarted
    var authorizationStatus = SFSpeechRecognizerAuthorizationStatus.notDetermined
    var utterance: String?
}

enum SpeechRecognitionAction {
    case buttonTapped
    case startRecording
    case stopRecording
    case subscribeToSpeechRecognitionStatus
    case setStatus(SpeechRecognitionStatus)
    case setUtterance(String?)
    case requestAuthorization
    case setAuthorizationStatus(SFSpeechRecognizerAuthorizationStatus)
}

struct SpeechRecognitionEnvironment {
    let engine: SpeechRecognitionEngine
}

func speechRecognitionReducer(
    state: inout SpeechRecognitionState,
    action: SpeechRecognitionAction,
    environment: SpeechRecognitionEnvironment
) -> AnyPublisher<SpeechRecognitionAction, Never>? {
    switch action {
    case .buttonTapped:
        switch state.status {
        case .recording:
            return Just(.stopRecording)
                .eraseToAnyPublisher()
        case .notStarted, .stopped:
            return Just(.startRecording)
                .eraseToAnyPublisher()
        case .stopping:
            break
        }
    case .startRecording:
        guard state.authorizationStatus == .authorized
        else { return Just(.requestAuthorization).eraseToAnyPublisher() }
        do {
            try environment.engine.startRecording()
            return environment.engine.newUtterance
                .map { .setUtterance($0) }
                .eraseToAnyPublisher()
        } catch {
            print(error)
            // FIXME: Should also notify the button state
        }
    case .stopRecording:
        environment.engine.stopRecording()
    case .subscribeToSpeechRecognitionStatus:
        return environment.engine.$recognitionStatus
            .map { .setStatus($0) }
            .eraseToAnyPublisher()
    case .setStatus(let status):
        state.status = status
        if status != .recording {
            state.utterance = nil
        }
    case .setUtterance(let utterance):
        state.utterance = utterance
    case .setAuthorizationStatus(let authorizationStatus):
        state.authorizationStatus = authorizationStatus
        if authorizationStatus == .authorized {
            return Just(.startRecording)
                .eraseToAnyPublisher()
        }
    case .requestAuthorization:
        // TODO: check if we still need the callback here...
        environment.engine.requestAuthorization { }
        return environment.engine.$authorizationStatus
            .map { .setAuthorizationStatus($0 ?? .notDetermined) }
            .eraseToAnyPublisher()
    }
    return nil
}
