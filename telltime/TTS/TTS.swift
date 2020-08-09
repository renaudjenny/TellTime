import Foundation
import Combine
import SwiftTTSCombine

enum TTS {
    struct State {
        var isSpeaking = false
        var speakingProgress = 0.0
        var rateRatio: Float = 1.0
    }

    enum Action {
        case changeRateRatio(Float)
        case tellTime(Date)
        case startSpeaking
        case stopSpeaking
        case changeSpeakingProgress(Double)
        case subscribeToEngineIsSpeaking
        case subscribeToEngineSpeakingProgress
    }

    struct Environment {
        let engine: TTSEngine
        let calendar: Calendar
        let tellTime: (Date, Calendar) -> String
    }

    static func reducer(
        state: inout TTS.State,
        action: TTS.Action,
        environment: TTS.Environment
    ) -> AnyPublisher<TTS.Action, Never>? {
        switch action {
        case let .changeRateRatio(rateRatio):
            state.rateRatio = rateRatio
            environment.engine.rateRatio = rateRatio
        case let .tellTime(date):
            let tellTimeText = environment.tellTime(date, environment.calendar)
            environment.engine.speak(string: tellTimeText)
        case .startSpeaking:
            state.isSpeaking = true
        case .stopSpeaking:
            state.isSpeaking = false
        case let .changeSpeakingProgress(speakingProgress):
            state.speakingProgress = speakingProgress
        case .subscribeToEngineIsSpeaking:
            return environment.engine.isSpeakingPublisher
                .map { $0 ? .startSpeaking : .stopSpeaking }
                .eraseToAnyPublisher()
        case .subscribeToEngineSpeakingProgress:
            return environment.engine.speakingProgressPublisher
                .map { .changeSpeakingProgress($0) }
                .eraseToAnyPublisher()
        }
        return nil
    }
}
