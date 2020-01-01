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
}
