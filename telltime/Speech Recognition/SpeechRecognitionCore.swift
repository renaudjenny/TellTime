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
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

typealias SpeechRecognitionReducer = Reducer<
    SpeechRecognitionState,
    SpeechRecognitionAction,
    SpeechRecognitionEnvironment
>
let speechRecognitionReducer = SpeechRecognitionReducer { state, action, environment in
    struct RecognitionStatusId: Hashable { }
    struct NewUtteranceId: Hashable { }
    struct AuthorizationStatusId: Hashable { }

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
                    .receive(on: environment.mainQueue)
                    .map { .setStatus($0) }
                    .eraseToEffect()
                    .cancellable(id: RecognitionStatusId()),
                environment.engine.newUtterancePublisher
                    .receive(on: environment.mainQueue)
                    .map { .setUtterance($0) }
                    .eraseToEffect()
                    .cancellable(id: NewUtteranceId())
            )
        } catch {
            return Effect(value: .stopRecording)
        }
    case .stopRecording:
        environment.engine.stopRecording()
        return .none
    case .setStatus(let status):
        state.status = status
        switch status {
        case .recording:
            state.utterance = nil
            state.recognizedTime = nil
        case .stopped:
            state.utterance = nil
            state.recognizedTime = nil
            return .merge(
                .cancel(id: NewUtteranceId()),
                .cancel(id: RecognitionStatusId())
            )
        default: break
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
        switch authorizationStatus {
        case .authorized:
            return .merge(
                Effect(value: .startRecording),
                .cancel(id: AuthorizationStatusId())
            )
        case .notDetermined:
            return .merge(
                Effect(value: .requestAuthorization),
                .cancel(id: AuthorizationStatusId())
            )
        default: break
        }
        return .cancel(id: AuthorizationStatusId())
    case .requestAuthorization:
        environment.engine.requestAuthorization()
        return environment.engine.authorizationStatusPublisher
            .receive(on: environment.mainQueue)
            .map { .setAuthorizationStatus($0 ?? .notDetermined) }
            .eraseToEffect()
            .cancellable(id: AuthorizationStatusId())
    case .setRecognizedDate(let date):
        state.recognizedTime = date
        return Effect(value: .stopRecording)
            .receive(on: environment.mainQueue)
            .delay(for: .seconds(2), scheduler: environment.mainQueue)
            .eraseToEffect()
    }
}
