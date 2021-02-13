import SwiftUI
import ComposableArchitecture
import Combine
import Speech

struct SpeechRecognitionState: Equatable {
    var status: SpeechRecognitionStatus = .notStarted
    var authorizationStatus = SFSpeechRecognizerAuthorizationStatus.notDetermined
    var utterance: String?
    var recognizedTime: Date?
}

enum SpeechRecognitionAction: Equatable {
    case buttonTapped
    case startRecording
    case stopRecording
    case setStatus(SpeechRecognitionStatus)
    case setUtterance(String?)
    case requestAuthorization
    case setAuthorizationStatus(SFSpeechRecognizerAuthorizationStatus)
    case setRecognizedDate(Date)
}

struct SpeechRecognitionEnvironment {
    var engine: SpeechRecognitionEngine
    var recognizeTime: (String, Calendar) -> Date?
    var calendar: Calendar
}

typealias SpeechRecognitionReducer = Reducer<SpeechRecognitionState, SpeechRecognitionAction, SpeechRecognitionEnvironment>
let speechRecognitionReducer = SpeechRecognitionReducer { state, action, environment in
    switch action {
    case .buttonTapped:
        switch state.status {
        case .recording, .stopping:
            return Effect(value: .stopRecording)
        case .notStarted, .stopped:
            return Effect(value: .startRecording)
        }
    case .startRecording:
        guard state.authorizationStatus == .authorized
        else { return Effect(value: .requestAuthorization) }
        do {
            try environment.engine.startRecording()
            return Effect.merge(
                environment.engine.recognitionStatusPublisher
                    .map { .setStatus($0) }
                    .eraseToEffect(),
                environment.engine.newUtterancePublisher
                    .map { .setUtterance($0) }
                    .eraseToEffect()
            )
        } catch {
            print(error)
            // FIXME: Should also notify the button state
            return .none
        }
    case .stopRecording:
        environment.engine.stopRecording()
        return .none
    case .setStatus(let status):
        state.status = status
        if status != .recording {
            state.utterance = nil
            state.recognizedTime = nil
        }
        return .none
    case .setUtterance(let utterance):
        state.utterance = utterance
        if let utterance = utterance,
           let recognizedTime = environment.recognizeTime(utterance, environment.calendar) {
            return Effect(value: .setRecognizedDate(recognizedTime))
        }
        return .none
    case .setAuthorizationStatus(let authorizationStatus):
        state.authorizationStatus = authorizationStatus
        if authorizationStatus == .authorized {
            return Effect(value: .startRecording)
        }
        return .none
    case .requestAuthorization:
        // TODO: check if we still need the callback here...
        environment.engine.requestAuthorization()
        return environment.engine.authorizationStatusPublisher
            .map { .setAuthorizationStatus($0 ?? .notDetermined) }
            .eraseToEffect()
    case .setRecognizedDate(let date):
        state.recognizedTime = date
        return Effect(value: .stopRecording)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .eraseToEffect()
    }
}
