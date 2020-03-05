import XCTest
@testable import Tell_Time_UK
import SwiftClockUI

class ConfigurationTests: XCTestCase {
    func testDefaultConfigurationValues() {
        let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
        XCTAssertEqual(store.state.configuration.clockStyle, .classic)
        XCTAssertEqual(store.state.configuration.clock, ClockConfiguration())
    }

    func testWhenIChangeTheClockStyleThenTheClockStyleGetTheNewValue() {
        let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
        XCTAssertEqual(store.state.configuration.clockStyle, .classic)
        store.send(.configuration(.changeClockStyle(.artNouveau)))
        XCTAssertEqual(store.state.configuration.clockStyle, .artNouveau)
        store.send(.configuration(.changeClockStyle(.drawing)))
        XCTAssertEqual(store.state.configuration.clockStyle, .drawing)
        store.send(.configuration(.changeClockStyle(.classic)))
        XCTAssertEqual(store.state.configuration.clockStyle, .classic)
    }

    func testWhenIWantToHideMinuteIndicatorsThenMinuteIndicatorsIsHidden() {
        let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
        XCTAssertEqual(store.state.configuration.clock.isMinuteIndicatorsShown, true)
        store.send(.configuration(.showMinuteIndicators(false)))
        XCTAssertEqual(store.state.configuration.clock.isMinuteIndicatorsShown, false)
        store.send(.configuration(.showMinuteIndicators(true)))
        XCTAssertEqual(store.state.configuration.clock.isMinuteIndicatorsShown, true)
    }

    func testWhenIWantToHideHourIndicatorsThenHourIndicatorsIsHidden() {
        let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
        XCTAssertEqual(store.state.configuration.clock.isHourIndicatorsShown, true)
        store.send(.configuration(.showHourIndicators(false)))
        XCTAssertEqual(store.state.configuration.clock.isHourIndicatorsShown, false)
        store.send(.configuration(.showHourIndicators(true)))
        XCTAssertEqual(store.state.configuration.clock.isHourIndicatorsShown, true)
    }

    func testWhenIWantToLimitHourDisplayedThenHourIsDisplayedWithALimitedAmount() {
        let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
        XCTAssertEqual(store.state.configuration.clock.isLimitedHoursShown, false)
        store.send(.configuration(.showLimitedHours(true)))
        XCTAssertEqual(store.state.configuration.clock.isLimitedHoursShown, true)
        store.send(.configuration(.showLimitedHours(false)))
        XCTAssertEqual(store.state.configuration.clock.isLimitedHoursShown, false)
    }
}

extension ClockConfiguration: Equatable {
    public static func == (lhs: ClockConfiguration, rhs: ClockConfiguration) -> Bool {
        lhs.isHourIndicatorsShown == rhs.isHourIndicatorsShown
            && lhs.isMinuteIndicatorsShown == rhs.isMinuteIndicatorsShown
            && lhs.isLimitedHoursShown == rhs.isLimitedHoursShown
    }
}
