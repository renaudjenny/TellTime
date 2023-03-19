import ComposableArchitecture
import Combine
import Foundation

public struct TTS: ReducerProtocol {
    public struct State: Equatable {
        var isSpeaking = false
        var speakingProgress = 0.0
        var rateRatio: Float = 1.0
    }

    public enum Action: Equatable {
        case changeRateRatio(Float)
        case tellTime(Date)
        case startSpeaking
        case stopSpeaking
        case changeSpeakingProgress(Double)
    }

//    struct TTSEnvironment {
//        var engine: TTSEngine
//        var calendar: Calendar
//        var tellTime: (Date, Calendar) -> String
//        var mainQueue: AnySchedulerOf<DispatchQueue>
//    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            struct IsSpeakingId: Hashable {}
            struct SpeakingProgressId: Hashable {}

            switch action {
            case let .changeRateRatio(rateRatio):
                state.rateRatio = rateRatio
//                environment.engine.rateRatio = rateRatio
                return .none
            case let .tellTime(date):
                let tellTimeText = ""// environment.tellTime(date, environment.calendar)
//                environment.engine.speak(string: tellTimeText)
//                return environment.engine.isSpeakingPublisher
//                    .receive(on: environment.mainQueue)
//                    .map { $0 ? .startSpeaking : .stopSpeaking }
//                    .eraseToEffect()
//                    .cancellable(id: IsSpeakingId())
                return .none
            case .startSpeaking:
                state.isSpeaking = true
//                return environment.engine.speakingProgressPublisher
//                    .receive(on: environment.mainQueue)
//                    .map { .changeSpeakingProgress($0) }
//                    .eraseToEffect()
//                    .cancellable(id: SpeakingProgressId())
                return .none
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
    }
}
