import ComposableArchitecture
import Combine
import SwiftTTSCombine

struct TTSState: Equatable {
    var isSpeaking = false
    var speakingProgress = 0.0
    var rateRatio: Float = 1.0
}

enum TTSAction {
    case changeRateRatio(Float)
    case tellTime(Date)
    case startSpeaking
    case stopSpeaking
    case changeSpeakingProgress(Double)
}

struct TTSEnvironment {
    let engine: TTSEngine
    let calendar: Calendar
    let tellTime: (Date, Calendar) -> String
}

let ttsReducer = Reducer<TTSState, TTSAction, TTSEnvironment> { state, action, environment in
    switch action {
    case let .changeRateRatio(rateRatio):
        state.rateRatio = rateRatio
        environment.engine.rateRatio = rateRatio
        return .none
    case let .tellTime(date):
        let tellTimeText = environment.tellTime(date, environment.calendar)
        environment.engine.speak(string: tellTimeText)
        return environment.engine.isSpeakingPublisher
            .map { $0 ? .startSpeaking : .stopSpeaking }
            .eraseToEffect()
    case .startSpeaking:
        state.isSpeaking = true
        return environment.engine.speakingProgressPublisher
            .map { .changeSpeakingProgress($0) }
            .eraseToEffect()
    case .stopSpeaking:
        state.isSpeaking = false
        return .none
    case let .changeSpeakingProgress(speakingProgress):
        state.speakingProgress = speakingProgress
        return .none
    }
}
