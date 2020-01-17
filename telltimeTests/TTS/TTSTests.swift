import XCTest
@testable import telltime
import SwiftUI

class TTSTests: XCTestCase {
  func testDefaultTTSValues() {
    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.tts.isSpeaking, false)
    XCTAssertEqual(store.state.tts.speakingProgress, 0)
    XCTAssertEqual(store.state.tts.rateRatio, 1)
  }

  func testWhenIChangeTheTTSRateRatioTheRateRatioOfEngineIsChanged() {
    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.tts.rateRatio, 1)
    let newRateRatio: Float = 0.75
    let engineSetRateRatioExpectation = self.expectation(description: "Engine ratio is set")
    Current.tts.setRateRatio = { rateRatio in
      XCTAssertEqual(newRateRatio, rateRatio)
      engineSetRateRatioExpectation.fulfill()
    }
    store.send(.tts(.changeRateRatio(newRateRatio)))
    XCTAssertEqual(newRateRatio, store.state.tts.rateRatio)
    self.wait(for: [engineSetRateRatioExpectation], timeout: 0.1)
  }

  func testTTSTellTime() {
    given("it's 10 o clock") {
      let tenHourInSecond: TimeInterval = 10 * 60 * 60
      let date = Date(timeIntervalSince1970: tenHourInSecond)
      let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)

      let speechExpectation = self.expectation(description: "TTS Speech has been called")
      Current.tts.speech = {
        XCTAssertEqual(date, $0)
        speechExpectation.fulfill()
      }

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
      let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
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
      let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
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
      let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
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
}
