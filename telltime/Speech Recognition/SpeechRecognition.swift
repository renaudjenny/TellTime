import SwiftUI
import Combine
import Speech

struct SpeechRecognitionState: Equatable {
    var status: SpeechRecognitionStatus = .notStarted
    var authorizationStatus = SFSpeechRecognizerAuthorizationStatus.notDetermined
    var utterance: String?
    var recognizedTime: Date?
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
    case setRecognizedDate(Date)
}

struct SpeechRecognitionEnvironment {
    let engine: SpeechRecognitionEngine
    let recognizeTime: (String, Calendar) -> Date?
    let calendar: Calendar
}

func speechRecognitionReducer(
    state: inout SpeechRecognitionState,
    action: SpeechRecognitionAction,
    environment: SpeechRecognitionEnvironment
) -> AnyPublisher<SpeechRecognitionAction, Never>? {
    switch action {
    case .buttonTapped:
        switch state.status {
        case .recording, .stopping:
            return Just(.stopRecording)
                .eraseToAnyPublisher()
        case .notStarted, .stopped:
            return Just(.startRecording)
                .eraseToAnyPublisher()
        }
    case .startRecording:
        guard state.authorizationStatus == .authorized
        else { return Just(.requestAuthorization).eraseToAnyPublisher() }
        do {
            try environment.engine.startRecording()
            return environment.engine.newUtterancePublisher
                .map { .setUtterance($0) }
                .eraseToAnyPublisher()
        } catch {
            print(error)
            // FIXME: Should also notify the button state
        }
    case .stopRecording:
        environment.engine.stopRecording()
    case .subscribeToSpeechRecognitionStatus:
        return environment.engine.recognitionStatusPublisher
            .map { .setStatus($0) }
            .eraseToAnyPublisher()
    case .setStatus(let status):
        state.status = status
        if status != .recording {
            state.utterance = nil
            state.recognizedTime = nil
        }
    case .setUtterance(let utterance):
        state.utterance = utterance
        if let utterance = utterance,
           let recognizedTime = environment.recognizeTime(utterance, environment.calendar) {
            return Just(.setRecognizedDate(recognizedTime))
                .eraseToAnyPublisher()
        }
    case .setAuthorizationStatus(let authorizationStatus):
        state.authorizationStatus = authorizationStatus
        if authorizationStatus == .authorized {
            return Just(.startRecording)
                .eraseToAnyPublisher()
        }
    case .requestAuthorization:
        // TODO: check if we still need the callback here...
        environment.engine.requestAuthorization { }
        return environment.engine.authorizationStatusPublisher
            .map { .setAuthorizationStatus($0 ?? .notDetermined) }
            .eraseToAnyPublisher()
    case .setRecognizedDate(let date):
        state.recognizedTime = date
        return Just(.stopRecording)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    return nil
}
