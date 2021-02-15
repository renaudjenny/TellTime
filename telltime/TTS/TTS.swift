import ComposableArchitecture
import Combine
import SwiftTTSCombine

struct TTSState: Equatable {
    var isSpeaking = false
    var speakingProgress = 0.0
    var rateRatio: Float = 1.0
}

enum TTSAction: Equatable {
    case changeRateRatio(Float)
    case tellTime(Date)
    case startSpeaking
    case stopSpeaking
    case changeSpeakingProgress(Double)
}

struct TTSEnvironment {
    var engine: TTSEngine
    var calendar: Calendar
    var tellTime: (Date, Calendar) -> String
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let ttsReducer = Reducer<TTSState, TTSAction, TTSEnvironment> { state, action, environment in
    struct IsSpeakingId: Hashable {}
    struct SpeakingProgressId: Hashable {}

    switch action {
    case let .changeRateRatio(rateRatio):
        state.rateRatio = rateRatio
        environment.engine.rateRatio = rateRatio
        return .none
    case let .tellTime(date):
        let tellTimeText = environment.tellTime(date, environment.calendar)
        environment.engine.speak(string: tellTimeText)
        return environment.engine.isSpeakingPublisher
            .receive(on: environment.mainQueue)
            .map { $0 ? .startSpeaking : .stopSpeaking }
            .eraseToEffect()
            .cancellable(id: IsSpeakingId())
    case .startSpeaking:
        state.isSpeaking = true
        return environment.engine.speakingProgressPublisher
            .receive(on: environment.mainQueue)
            .map { .changeSpeakingProgress($0) }
            .eraseToEffect()
            .cancellable(id: SpeakingProgressId())
    case .stopSpeaking:
        state.isSpeaking = false
        return .merge(
            .cancel(id: SpeakingProgressId()),
            .cancel(id: IsSpeakingId())
        )
    case let .changeSpeakingProgress(speakingProgress):
        state.speakingProgress = speakingProgress
        return .none
    }
}
