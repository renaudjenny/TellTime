import XCTest
@testable import telltime
import SwiftUI

class ClockTests: XCTestCase {
  func testClockDefaultValues() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4300)
    Current.date = { fakeCurrentDate }

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.clock.date, fakeCurrentDate)
    XCTAssertEqual(store.state.clock.isClockFaceShown, false)
    XCTAssertEqual(store.state.clock.hourAngle, .zero)
    XCTAssertEqual(store.state.clock.hourAngle, .zero)
  }

  func testWhenIChangeTheDateThenTheHourAngleAndMinuteAngleChangedAsWell() {
    let date10past10 = Date(timeIntervalSince1970: 36600)

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    store.send(.clock(.changeDate(date10past10)))
    XCTAssertEqual(store.state.clock.date, date10past10)
    XCTAssertEqual(store.state.clock.hourAngle, .degrees(335))
    XCTAssertEqual(store.state.clock.minuteAngle, .degrees(60))
  }
}
