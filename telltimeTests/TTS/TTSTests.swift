import XCTest
@testable import Tell_Time_UK
import SwiftUI
import Combine
import SwiftTTSCombine
import AVFoundation

class TTSTests: XCTestCase {
    func testDefaultTTSValues() {
        let store = testStore
        XCTAssertEqual(store.state.tts.isSpeaking, false)
        XCTAssertEqual(store.state.tts.speakingProgress, 0)
        XCTAssertEqual(store.state.tts.rateRatio, 1)
    }

    func testWhenIChangeTheTTSRateRatioTheRateRatioOfEngineIsChanged() {
        let newRateRatio: Float = 0.75
        let engineSetRateRatioExpectation = self.expectation(description: "Engine ratio is set")
        let engine = MockedTTSEngine(
            setRateRatio: { rateRatio in
                XCTAssertEqual(newRateRatio, rateRatio)
                engineSetRateRatioExpectation.fulfill()
            }
        )
        let store = testStore(environment: .test(engine: engine))

        XCTAssertEqual(store.state.tts.rateRatio, 1)
        store.send(.tts(.changeRateRatio(newRateRatio)))
        XCTAssertEqual(newRateRatio, store.state.tts.rateRatio)
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
            let store = testStore(environment: .test(engine: engine))

            when("I trigger the action to tell the time") {
                store.send(.tts(.tellTime(date)))

                then("The TTS Speech function is called with the current date") {
                    self.wait(for: [speechExpectation], timeout: 0.1)
                }
            }
        }
    }

    func testTTSStartSpeaking() {
        given("TTS is not currently speaking because I just started the application") {
            let store = testStore
            XCTAssertEqual(false, store.state.tts.isSpeaking)

            when("I trigger the action for speaking") {
                store.send(.tts(.startSpeaking))

                then("the the TTS state is speaking") {
                    XCTAssertEqual(true, store.state.tts.isSpeaking)
                }
            }
        }
    }

    func testTTSStopSpeaking() {
        given("TTS is currently speaking") {
            let store = testStore
            store.send(.tts(.startSpeaking))
            XCTAssertEqual(true, store.state.tts.isSpeaking)

            when("the utterance ends, an action is triggered") {
                store.send(.tts(.stopSpeaking))

                then("the the TTS state is not speaking") {
                    XCTAssertEqual(false, store.state.tts.isSpeaking)
                }
            }
        }
    }

    func testTTSSpeakingProgress() {
        given("TTS start speaking") {
            let store = testStore
            XCTAssertEqual(0, store.state.tts.speakingProgress)

            when("the utterance progress, 50% for instance") {
                let progress: Double = 50/100
                store.send(.tts(.changeSpeakingProgress(progress)))

                then("the the TTS state is not speaking") {
                    XCTAssertEqual(progress, store.state.tts.speakingProgress)
                }
            }
        }
    }

    func testSubscribeToEngineIsSpeaking() {
        given("the subscription to TTS engine is speaking event is made") {
            let engine = MockedTTSEngine(
                isSpeakingPublisher: Just(true).eraseToAnyPublisher()
            )
            let store = testStore(environment: .test(engine: engine))
            XCTAssertEqual(false, store.state.tts.isSpeaking)

            store.send(.tts(.subscribeToEngineIsSpeaking))

            when("the TTS engine start speaking") {
                let publisherExpectation = self.expectation(description: "isSpeakingPublisher completion")
                let isSpeakingPublisher = engine.isSpeakingPublisher
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
                XCTAssertNotNil(isSpeakingPublisher)

                then("the start speaking action is triggered") {
                    self.wait(for: [publisherExpectation], timeout: 0.1)
                    XCTAssertEqual(true, store.state.tts.isSpeaking)
                }
            }
        }
    }

    func testSubscribeToEngineIsSpeakingAndItsNotSpeaking() {
        given("the subscription to TTS engine is speaking event is made") {
            let engine = MockedTTSEngine(
                isSpeakingPublisher: Just(false).eraseToAnyPublisher()
            )
            let store = testStore(environment: .test(engine: engine))
            store.send(.tts(.startSpeaking))
            XCTAssertEqual(true, store.state.tts.isSpeaking)

            store.send(.tts(.subscribeToEngineIsSpeaking))

            when("the TTS engine stop speaking") {
                let publisherExpectation = self.expectation(description: "isSpeakingPublisher completion")
                let isSpeakingPublisher = engine.isSpeakingPublisher
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
                XCTAssertNotNil(isSpeakingPublisher)

                then("the start speaking action is triggered") {
                    self.wait(for: [publisherExpectation], timeout: 0.1)
                    XCTAssertEqual(false, store.state.tts.isSpeaking)
                }
            }
        }
    }

    func testSubscribeToEngineSpeakingProgress() {
        given("the subscription to TTS engine speaking progress event is made") {
            let engine = MockedTTSEngine(speakingProgressPublisher: Just(0).eraseToAnyPublisher())
            let store = testStore(environment: .test(engine: engine))
            XCTAssertEqual(0, store.state.tts.speakingProgress)

            engine.speakingProgressPublisher = Just(1/4).eraseToAnyPublisher()
            store.send(.tts(.subscribeToEngineSpeakingProgress))

            when("the TTS engine speaking is progressing (1/4)") {
                let publisherExpectation = self.expectation(description: "speakingProgressPublisher completion")
                let isSpeakingPublisher = engine.speakingProgressPublisher
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
                XCTAssertNotNil(isSpeakingPublisher)

                then("the speaking progress action is triggered with 1/4") {
                    self.wait(for: [publisherExpectation], timeout: 0.1)
                    XCTAssertEqual(1/4, store.state.tts.speakingProgress)
                }
            }
        }

        given("the subscription to TTS engine speaking progress event is made") {
            let engine = MockedTTSEngine(speakingProgressPublisher: Just(0).eraseToAnyPublisher())
            let store = testStore(environment: .test(engine: engine))

            engine.speakingProgressPublisher = Just(3/4).eraseToAnyPublisher()
            store.send(.tts(.subscribeToEngineSpeakingProgress))

            when("the TTS engine speaking is progressing (3/4)") {
                let publisherExpectation = self.expectation(
                    description: "speakingProgressPublisher completion"
                )
                let isSpeakingPublisher = engine.speakingProgressPublisher
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
                XCTAssertNotNil(isSpeakingPublisher)

                then("the speaking progress action is triggered with 3/4") {
                    self.wait(for: [publisherExpectation], timeout: 0.1)
                    XCTAssertEqual(3/4, store.state.tts.speakingProgress)
                }
            }
        }
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

extension AppEnvironment {
    static func test(engine: TTSEngine) -> Self {
        .init(
            currentDate: { Date() },
            tts: TTSEnvironment(
                engine: engine,
                calendar: .test,
                tellTime: { date, _ in date.description  }
            )
        )
    }
}
