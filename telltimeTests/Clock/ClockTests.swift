import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI
import Combine

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
    let tenHourInSecond: TimeInterval = 10 * 60 * 60
    let tenMinutesInSecond: TimeInterval = 10 * 60
    let date10past10 = Date(timeIntervalSince1970: tenHourInSecond + tenMinutesInSecond)
    let tenHourTenMinuteAngles: (hour: Angle, minute: Angle) = (
      hour: .degrees(360/12 * (10 + 1/6)),
      minute: .degrees(360/60 * 10)
    )

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    store.send(.clock(.changeDate(date10past10)))
    XCTAssertEqual(store.state.clock.date, date10past10)
    XCTAssertEqual(store.state.clock.hourAngle, tenHourTenMinuteAngles.hour)
    XCTAssertEqual(store.state.clock.minuteAngle, tenHourTenMinuteAngles.minute)
  }

  func testWhenIShowTheClockThenTheClockFaceIsShown() {
    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.clock.isClockFaceShown, false)
    store.send(.clock(.showClockFace))
    XCTAssertEqual(store.state.clock.isClockFaceShown, true)
    store.send(.clock(.hideClockFace))
    XCTAssertEqual(store.state.clock.isClockFaceShown, false)
  }

  func testWhenIShowTheClockFaceAndDelayTheClockFaceHiddingThenTwoSecondsLaterTheFaceIsHidden() {
    Current.clockFaceShownTimeInterval = 0.01
    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.clock.isClockFaceShown, false)
    store.send(.clock(.showClockFace))
    store.send(App.SideEffect.clock(Clock.SideEffect.delayClockFaceHidding))
    XCTAssertEqual(store.state.clock.isClockFaceShown, true)
    let waitForFewSecondsExpectation = self.expectation(description: "Delay for the Face to be shown")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      waitForFewSecondsExpectation.fulfill()
    }
    self.wait(for: [waitForFewSecondsExpectation], timeout: 0.5)
    XCTAssertEqual(store.state.clock.isClockFaceShown, false)
  }

  func testWhenIChangeTheHourAngleThenTheDateAndAngleHaveChanged() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 0)
    Current.date = { fakeCurrentDate }
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.clock.hourAngle, .zero)
    let oneHourAngle = Angle(degrees: 360/12)
    store.send(.clock(.changeHourAngle(oneHourAngle)))
    let oneHourInSeconds: TimeInterval = 60 * 60
    XCTAssertEqual(store.state.clock.date, Date(timeIntervalSince1970: oneHourInSeconds))
    XCTAssertEqual(store.state.clock.hourAngle, oneHourAngle)
  }

  func testWhenIChangeTheMinuteAngleThenTheDateAndAnglesHaveChanged() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 0)
    Current.date = { fakeCurrentDate }
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.clock.hourAngle, .zero)
    XCTAssertEqual(store.state.clock.minuteAngle, .zero)

    let fiveteenMinutesAngles: (hour: Angle, minute: Angle) = (
      hour: .degrees(360/12 * 1/4),
      minute: .degrees(360/60 * 15)
    )
    store.send(.clock(.changeMinuteAngle(fiveteenMinutesAngles.minute)))
    let fiveteenMinutesInSeconds: TimeInterval = 15 * 60
    XCTAssertEqual(store.state.clock.date, Date(timeIntervalSince1970: fiveteenMinutesInSeconds))
    XCTAssertEqual(store.state.clock.hourAngle, fiveteenMinutesAngles.hour)
    XCTAssertEqual(store.state.clock.minuteAngle, fiveteenMinutesAngles.minute)
  }

  func testWhenIChangeTheDateRandomlyThenTheDateAndAnglesAreChanhedRandomly() {
    let fakeCurrentDate = Date(timeIntervalSince1970: 0)
    Current.date = { fakeCurrentDate }
    Current.calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
    let oneHourInSecond: TimeInterval = 60 * 60
    let twentyMinutesInSecond: TimeInterval = 20 * 60
    let randomDate = Date(timeIntervalSince1970: oneHourInSecond + twentyMinutesInSecond)
    let oneHourTwentyMinutesAngles: (hour: Angle, minute: Angle) = (
      hour: .degrees(360/12 * (1 + 1/3)),
      minute: .degrees(360/60 * 20)
    )

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.clock.date, fakeCurrentDate)
    XCTAssertEqual(store.state.clock.hourAngle, .zero)
    XCTAssertEqual(store.state.clock.minuteAngle, .zero)

    Current.randomDate = { randomDate }

    store.send(.clock(.changeClockRandomly))
    XCTAssertEqual(store.state.clock.date, randomDate)
    XCTAssertEqual(store.state.clock.hourAngle, oneHourTwentyMinutesAngles.hour)
    XCTAssertEqual(store.state.clock.minuteAngle, oneHourTwentyMinutesAngles.minute)
  }

  func testClockViews() {
    Current.isOnAppearAnimationDisabled = true
    let clockViews = ClockView_Previews.previews
    let hostingController = UIHostingController(rootView: clockViews)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
