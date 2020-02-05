import XCTest
@testable import Tell_Time_UK

class TelltimeTests: XCTestCase {
  func testWhenIStartTheApplicationThenTheStoreDateIsTheCurrentOne() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4300)
    Current.date = { fakeCurrentDate }
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)

    XCTAssertEqual(Current.tts.time(store.state.clock.date), "It's one eleven AM.")
  }

  func testWhenIChangedTheDateThenICanReadLiteralTimeFromIt() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 4360)
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    store.send(.clock(.changeDate(fakeCurrentDate)))

    XCTAssertEqual(Current.tts.time(store.state.clock.date), "It's one twelve AM.")
  }
}
