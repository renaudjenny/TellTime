import XCTest
@testable import telltime

class TelltimeTests: XCTestCase {
  func testWhenIStartTheApplicationThenTheStoreDateIsTheCurrentOne() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4300)
    Current.date = { fakeCurrentDate }
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)

    XCTAssertEqual(store.state.time, "It's one eleven AM.")
  }

  func testWhenIChangedTheDateThenICanReadLiteralTimeFromIt() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4360)
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    store.send(.clock(.changeDate(fakeCurrentDate)))

    XCTAssertEqual(store.state.time, "It's one twelve AM.")
  }
}
