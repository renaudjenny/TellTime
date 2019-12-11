import XCTest
@testable import telltime
import SwiftUI

class ReadLiteralTimeTests: XCTestCase {
  func testWhenIStartTheApplicationThenTheStoreDateIsTheCurrentOne() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4300)
    Current.date = { fakeCurrentDate }

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)

    XCTAssertEqual(store.state.time, "It's two eleven AM.")
  }

  func testWhenIChangedTheDateThenICanReadLiteralTimeFromIt() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4360)

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    store.send(.clock(.changeDate(fakeCurrentDate)))

    XCTAssertEqual(store.state.time, "It's two twelve AM.")
  }
}
