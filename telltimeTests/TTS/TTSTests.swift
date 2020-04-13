import XCTest
@testable import Tell_Time_UK
import SwiftUI
import Combine

class TTSTests: XCTestCase {
    func testDefaultTTSValues() {
        let store = App.testStore
        XCTAssertEqual(store.state.tts.isSpeaking, false)
        XCTAssertEqual(store.state.tts.speakingProgress, 0)
        XCTAssertEqual(store.state.tts.rateRatio, 1)
    }

    func testWhenIChangeTheTTSRateRatioTheRateRatioOfEngineIsChanged() {
        let defaultRateRatio: Float = 1.0
        let newRateRatio: Float = 0.75
        let engineSetRateRatioExpectation = self.expectation(description: "Engine ratio is set")
        let engine = MockedTTSEngine(
            rateRatioValue: defaultRateRatio,
            setRateRatio: { rateRatio in
                XCTAssertEqual(newRateRatio, rateRatio)
                engineSetRateRatioExpectation.fulfill()
            }
        )
        let environment = App.Environment(currentDate: { Date() }, tts: TTS.Environment(engine: engine))
        let store = App.testStore(environment: environment)

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
                rateRatioValue: 1.0,
                setRateRatio: { _ in },
                speechExpectation: speechExpectation
            )
            let environment = App.Environment(currentDate: { Date() }, tts: TTS.Environment(engine: engine))
            let store = App.testStore(environment: environment)

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
            let store = App.testStore
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
            let store = App.testStore
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
            let store = App.testStore
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
            let store = App.testStore
            XCTAssertEqual(false, store.state.tts.isSpeaking)

            Current.tts.isSpeakingPublisher = Just(true).eraseToAnyPublisher()
            store.send(.tts(.subscribeToEngineIsSpeaking))

            when("the TTS engine start speaking") {
                let publisherExpectation = self.expectation(description: "Current.tts.isSpeakingPublisher completion")
                let isSpeakingPublisher = Current.tts.isSpeakingPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished: publisherExpectation.fulfill()
                            case .failure: XCTFail("Current.tts.isSpeakingPublisher completion has failed")
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

        given("the subscription to TTS engine is speaking event is made") {
            let store = App.testStore
            store.send(.tts(.startSpeaking))
            XCTAssertEqual(true, store.state.tts.isSpeaking)

            Current.tts.isSpeakingPublisher = Just(false).eraseToAnyPublisher()
            store.send(.tts(.subscribeToEngineIsSpeaking))

            when("the TTS engine stop speaking") {
                let publisherExpectation = self.expectation(description: "Current.tts.isSpeakingPublisher completion")
                let isSpeakingPublisher = Current.tts.isSpeakingPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished: publisherExpectation.fulfill()
                            case .failure: XCTFail("Current.tts.isSpeakingPublisher completion has failed")
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
            let store = App.testStore
            XCTAssertEqual(0, store.state.tts.speakingProgress)

            Current.tts.speakingProgressPublisher = Just(1/4).eraseToAnyPublisher()
            store.send(.tts(.subscribeToEngineSpeakingProgress))

            when("the TTS engine speaking is progressing (1/4)") {
                let publisherExpectation = self.expectation(description: "Current.tts.speakingProgressPublisher completion")
                let isSpeakingPublisher = Current.tts.speakingProgressPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished: publisherExpectation.fulfill()
                            case .failure: XCTFail("Current.tts.isSpeakingPublisher completion has failed")
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
            let store = App.testStore
            XCTAssertEqual(0, store.state.tts.speakingProgress)

            Current.tts.speakingProgressPublisher = Just(3/4).eraseToAnyPublisher()
            store.send(.tts(.subscribeToEngineSpeakingProgress))

            when("the TTS engine speaking is progressing (3/4)") {
                let publisherExpectation = self.expectation(
                    description: "Current.tts.speakingProgressPublisher completion"
                )
                let isSpeakingPublisher = Current.tts.speakingProgressPublisher
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished: publisherExpectation.fulfill()
                            case .failure: XCTFail("Current.tts.isSpeakingPublisher completion has failed")
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
        let setRateRatio: (Float) -> Void
        let speechExpectation: XCTestExpectation?

        init(
            rateRatioValue: Float,
            setRateRatio: @escaping (Float) -> Void,
            speechExpectation: XCTestExpectation? = nil
        ) {
            self.rateRatioValue = rateRatioValue
            self.setRateRatio = setRateRatio
            self.speechExpectation = speechExpectation
        }

        var rateRatio: Float {
            get { rateRatioValue }
            set { setRateRatio(newValue) }
        }

        func speech(date: Date) {
            speechExpectation?.fulfill()
        }
    }
}
