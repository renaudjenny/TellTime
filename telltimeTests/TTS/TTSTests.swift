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
}
