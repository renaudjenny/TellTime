import XCTest
@testable import telltime
import SwiftUI

class ReadLiteralTimeTests: XCTestCase {
  func testWhenIChangedTheDateThenICanReadLiteralTimeFromIt() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4320)

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    store.send(.clock(.changeDate(fakeCurrentDate)))

    XCTAssertEqual(store.state.time, "It's two twelve AM.")
  }
}
