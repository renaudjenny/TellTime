import XCTest
@testable import Tell_Time_UK
import SwiftUI
import Combine
import ComposableArchitecture
import SwiftTTSCombine
import AVFoundation

class TTSTests: XCTestCase {
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
        XCTAssertEqual(engine.rateRatio, newRateRatio)
        self.wait(for: [engineSetRateRatioExpectation], timeout: 0.1)
    }

    func testTTSTellTime() {
        given("it's 10 o clock") {
            let tenHourInSecond: TimeInterval = 10 * 60 * 60
            let date = Date(timeIntervalSince1970: tenHourInSecond)
            let speechExpectation = self.expectation(description: "TTS Speech has been called")
            let engine = MockedTTSEngine(
                speakCall: { spokenString in
                    XCTAssertEqual(spokenString, date.description)
                    speechExpectation.fulfill()
                }
            )
            let store = TestStore(
                initialState: AppState(),
                reducer: appReducer,
                environment: .test {
                    $0.ttsEngine = engine
                }
            )

            when("I trigger the action to tell the time") {
                store.assert(.send(.tts(.tellTime(date))))

                then("The TTS Speech function is called with the current date") {
                    self.wait(for: [speechExpectation], timeout: 0.1)
                }
            }
        }
    }

    func testTTSStartAndStopSpeaking() {
        let store = TestStore(initialState: AppState(), reducer: appReducer, environment: .test)

        store.assert(
            .send(.tts(.startSpeaking)) {
                $0.tts.isSpeaking = true
            },
            .send(.tts(.stopSpeaking)) {
                $0.tts.isSpeaking = false
            }
        )
    }

    func testTTSSpeakingProgress() {
        let store = TestStore(initialState: AppState(), reducer: appReducer, environment: .test)

        store.assert(
            .send(.tts(.changeSpeakingProgress(50/100))) {
                $0.tts.speakingProgress = 50/100
            }
        )
    }

    func testIsSpeakingUpdateFromEngineWhenStartSpeaking() {
        let engine = MockedTTSEngine(
            isSpeakingPublisher: Just(true).eraseToAnyPublisher()
        )
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .test {
                $0.ttsEngine = engine
            }
        )

        let publisherExpectation = self.expectation(description: "isSpeakingPublisher completion")

        store.assert(
            .send(.tts(.tellTime(Date()))),
            .environment { environment in
                _ = environment.ttsEngine.isSpeakingPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished: publisherExpectation.fulfill()
                            case .failure: XCTFail("isSpeakingPublisher completion has failed")
                            }
                        },
                        receiveValue: { XCTAssertEqual(true, $0) }
                    )
            },
            .receive(.tts(.startSpeaking)) {
                $0.tts.isSpeaking = true
            }
        )
    }

    func testIsSpeakingUpdateFromEngineWhenStopSpeaking() {
        let engine = MockedTTSEngine(
            isSpeakingPublisher: Just(false).eraseToAnyPublisher()
        )
        let store = TestStore(
            initialState: AppState.preview {
                $0.tts.isSpeaking = true
            },
            reducer: appReducer,
            environment: .test {
                $0.ttsEngine = engine
            }
        )

        let publisherExpectation = self.expectation(description: "isSpeakingPublisher completion")

        store.assert(
            .send(.tts(.tellTime(Date()))),
            .environment { environment in
                _ = environment.ttsEngine.isSpeakingPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished: publisherExpectation.fulfill()
                            case .failure: XCTFail("isSpeakingPublisher completion has failed")
                            }
                        },
                        receiveValue: { XCTAssertEqual(false, $0) }
                    )
            },
            .receive(.tts(.stopSpeaking)) {
                $0.tts.isSpeaking = true
            }
        )
    }

    func testSpeakingProgressUpdateFromEngine() {
            let engine = MockedTTSEngine(speakingProgressPublisher: Just(0).eraseToAnyPublisher())
            let store = TestStore(
                initialState: AppState.preview {
                    $0.tts.isSpeaking = true
                },
                reducer: appReducer,
                environment: .test {
                    $0.ttsEngine = engine
                }
            )

            engine.speakingProgressPublisher = Just(1/4).eraseToAnyPublisher()

        let publisherExpectation = self.expectation(description: "speakingProgressPublisher completion")

        store.assert(
            .send(.tts(.startSpeaking)) {
                $0.tts.isSpeaking = true
            },
            .environment { environment in
                _ = engine.speakingProgressPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished: publisherExpectation.fulfill()
                            case .failure: XCTFail("isSpeakingPublisher completion has failed")
                            }
                        },
                        receiveValue: { XCTAssertEqual(1/4, $0) }
                    )
            },
            .receive(.tts(.changeSpeakingProgress(1/4))) {
                $0.tts.speakingProgress = 1/4
            },
            .environment { environment in
                // TODO: IMO we should reproduce this schema for the other ones
                environment.ttsEngine = MockedTTSEngine(speakingProgressPublisher: Just(4/4).eraseToAnyPublisher())

                _ = engine.speakingProgressPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished: publisherExpectation.fulfill()
                            case .failure: XCTFail("isSpeakingPublisher completion has failed")
                            }
                        },
                        receiveValue: { XCTAssertEqual(3/4, $0) }
                    )
            },
            .receive(.tts(.changeSpeakingProgress(3/4))) {
                $0.tts.speakingProgress = 3/4
            }
        )
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
