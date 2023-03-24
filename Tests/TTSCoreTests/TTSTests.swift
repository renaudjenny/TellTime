import ComposableArchitecture
import TTSCore
import XCTest

@MainActor
class TTSTests: XCTestCase {
    let scheduler = DispatchQueue.test

    func testUpdateRatio() async {
        let setRatioExpectation = expectation(description: "TTS Set ratio is called")
        let store = TestStore(initialState: TTS.State(), reducer: TTS()) {
            $0.tts.setRateRatio = { value in
                XCTAssertEqual(value, 0.75)
                setRatioExpectation.fulfill()
            }
        }

        await store.send(.changeRateRatio(0.75)) {
            $0.rateRatio = 0.75
        }

        wait(for: [setRatioExpectation], timeout: 0.1)
    }

    func testTTSSpeak() async {
        let utterance = "It's ten o'clock"
        let speechExpectation = expectation(description: "TTS Speech is called")
        let isSpeakingExpectation = expectation(description: "TTS isSpeking is called")
        let speakingProgressExpectation = expectation(description: "TTS speaking progress is called")
        var isSpeakingCallback: () -> Void = { }
        var speakingProgressCallback: () -> Void = { }
        let store = TestStore(initialState: TTS.State(text: utterance), reducer: TTS()) {
            $0.tts.speak = { text in
                XCTAssertEqual(text, utterance)
                speechExpectation.fulfill()
            }
            $0.tts.isSpeaking = { AsyncStream { continuation in
                isSpeakingCallback = {
                    continuation.yield(true)
                    continuation.finish()
                    isSpeakingExpectation.fulfill()
                }
            } }
            $0.tts.speakingProgress = { AsyncStream { continuation in
                speakingProgressCallback = {
                    continuation.yield(0.5)
                    continuation.finish()
                    speakingProgressExpectation.fulfill()
                }
            } }
        }

        await store.send(.speak)

        isSpeakingCallback()
        await store.receive(.startSpeaking) {
            $0.isSpeaking = true
        }

        speakingProgressCallback()
        await store.receive(.changeSpeakingProgress(0.5)) {
            $0.speakingProgress = 0.5
        }

        wait(
            for: [speechExpectation, isSpeakingExpectation, speakingProgressExpectation],
            timeout: 0.1
        )
    }
}
