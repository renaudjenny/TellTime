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

  func testWhenIShowTheClockThenTheClockFaceIsShown() {
    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.clock.isClockFaceShown, false)
    store.send(.clock(.showClockFace))
    XCTAssertEqual(store.state.clock.isClockFaceShown, true)
    store.send(.clock(.hideClockFace))
    XCTAssertEqual(store.state.clock.isClockFaceShown, false)
  }

  func testWhenIChangeTheHourAngleThenTheDateAndAngleHaveChanged() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 0)
    Current.date = { fakeCurrentDate }
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.clock.hourAngle, .zero)
    let oneHourAngle = Angle(degrees: 30)
    store.send(.clock(.changeHourAngle(oneHourAngle)))
    let oneHourInSeconds: TimeInterval = 60 * 60
    XCTAssertEqual(store.state.clock.date, Date(timeIntervalSince1970: oneHourInSeconds))
    XCTAssertEqual(store.state.clock.hourAngle, oneHourAngle)
  }
}
