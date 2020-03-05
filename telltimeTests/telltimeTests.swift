import XCTest
@testable import Tell_Time_UK

class TelltimeTests: XCTestCase {
  func testWhenIStartTheApplicationThenTheStoreDateIsTheCurrentOne() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4300)
    Current.date = { fakeCurrentDate }
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)

    XCTAssertEqual(Current.tellTime(store.state.date), "It's one eleven AM.")
  }

  func testWhenIChangedTheDateThenICanReadLiteralTimeFromIt() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4360)
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    store.send(.changeDate(fakeCurrentDate))

    XCTAssertEqual(Current.tellTime(store.state.date), "It's one twelve AM.")
  }
}
