import ComposableArchitecture
import Foundation
import SwiftTTSDependency

public struct TTS: ReducerProtocol {
    public struct State: Equatable {
        public var text = ""
        public var isSpeaking = false
        public var speakingProgress = 1.0
        public var rateRatio: Float = 1.0

        public init(
            text: String = "",
            isSpeaking: Bool = false,
            speakingProgress: Double = 1.0,
            rateRatio: Float = 1.0
        ) {
            self.text = text
            self.isSpeaking = isSpeaking
            self.speakingProgress = speakingProgress
            self.rateRatio = rateRatio
        }
    }

    public enum Action: Equatable {
        case changeRateRatio(Float)
        case speak
        case startSpeaking
        case stopSpeaking
        case changeSpeakingProgress(Double)
    }

    @Dependency(\.tts) var tts

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .changeRateRatio(rateRatio):
                state.rateRatio = rateRatio
                tts.setRateRatio(rateRatio)
                return .none
            case .speak:
                tts.speak(state.text)
                return .run { send in
                    for await isSpeaking in tts.isSpeaking() {
                        if isSpeaking {
                            await send(.startSpeaking)
                        } else {
                            await send(.stopSpeaking)
                        }
                    }
                }
            case .startSpeaking:
                state.isSpeaking = true
                return .run { send in
                    for await progress in tts.speakingProgress() {
                        await send(.changeSpeakingProgress(progress))
                    }
                }
            case .stopSpeaking:
                state.isSpeaking = false
                return .none
            case let .changeSpeakingProgress(speakingProgress):
                state.speakingProgress = speakingProgress
                return .none
            }
        }
    }
}
