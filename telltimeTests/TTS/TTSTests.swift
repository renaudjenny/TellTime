import XCTest
@testable import Tell_Time_UK
import SwiftUI
import Combine
import ComposableArchitecture
import SwiftTTSCombine
import AVFoundation

class TTSTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler

    func testWhenIChangeTheTTSRateRatioTheRateRatioOfEngineIsChanged() {
        let newRateRatio: Float = 0.75
        let engineSetRateRatioExpectation = self.expectation(description: "Engine ratio is set")
        let engine = MockedTTSEngine(
            setRateRatio: { rateRatio in
                XCTAssertEqual(newRateRatio, rateRatio)
                engineSetRateRatioExpectation.fulfill()
            }
        )
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .test {
                $0.ttsEngine = engine
            }
        )

        store.assert(
            .send(.tts(.changeRateRatio(newRateRatio))) {
                $0.tts.rateRatio = newRateRatio
            }
        )
        self.wait(for: [engineSetRateRatioExpectation], timeout: 0.1)
    }

    func testTTSTellTime() {
        let tenHourInSecond: TimeInterval = 10 * 60 * 60
        let date = Date(timeIntervalSince1970: tenHourInSecond)
        let speechExpectation = self.expectation(description: "TTS Speech has been called")
        let isSpeakingPublisher = PassthroughSubject<Bool, Never>()
        let speakingProgressPublisher = PassthroughSubject<Double, Never>()
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .test {
                $0.mainQueue = self.scheduler.eraseToAnyScheduler()
                $0.ttsEngine = MockedTTSEngine(
                    speakCall: { spokenString in
                        XCTAssertEqual(spokenString, date.description)
                        speechExpectation.fulfill()
                    },
                    isSpeakingPublisher: isSpeakingPublisher.eraseToAnyPublisher(),
                    speakingProgressPublisher: speakingProgressPublisher.eraseToAnyPublisher()
                )
                $0.tellTime = { date, _ in date.description }
            }
        )

        store.assert(
            .send(.tts(.tellTime(date))),
            .do {
                isSpeakingPublisher.send(true)
                self.scheduler.advance()
            },
            .receive(.tts(.startSpeaking)) {
                $0.tts.isSpeaking = true
            },
            .do {
                speakingProgressPublisher.send(1/4)
                self.scheduler.advance()
            },
            .receive(.tts(.changeSpeakingProgress(1/4))) {
                $0.tts.speakingProgress = 1/4
            },
            .do {
                speakingProgressPublisher.send(3/4)
                self.scheduler.advance()
            },
            .receive(.tts(.changeSpeakingProgress(3/4))) {
                $0.tts.speakingProgress = 3/4
            },
            .do {
                isSpeakingPublisher.send(false)
                self.scheduler.advance()
            },
            .receive(.tts(.stopSpeaking)) {
                $0.tts.isSpeaking = false
            }
        )

        self.wait(for: [speechExpectation], timeout: 0.1)
    }
}

extension TTSTests {
    final class MockedTTSEngine: TTSEngine {
        let rateRatioValue: Float
        let setRateRatio: ((Float) -> Void)?
        var voice: AVSpeechSynthesisVoice?
        var speakCall: ((String) -> Void)?
        var isSpeakingPublisher: AnyPublisher<Bool, Never>
        var speakingProgressPublisher: AnyPublisher<Double, Never>

        init(
            rateRatioValue: Float = 1.0,
            setRateRatio: ((Float) -> Void)? = nil,
            speakCall: ((String) -> Void)? = nil,
            isSpeakingPublisher: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher(),
            speakingProgressPublisher: AnyPublisher<Double, Never> = Just(0.0).eraseToAnyPublisher()
        ) {
            self.rateRatioValue = rateRatioValue
            self.setRateRatio = setRateRatio
            self.speakCall = speakCall
            self.isSpeakingPublisher = isSpeakingPublisher
            self.speakingProgressPublisher = speakingProgressPublisher
        }

        var rateRatio: Float {
            get { rateRatioValue }
            set { setRateRatio?(newValue) }
        }

        func speak(string: String) {
            speakCall?(string)
        }
    }
}
