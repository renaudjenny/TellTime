import XCTest
@testable import Tell_Time_UK
import SwiftClockUI
import ComposableArchitecture

class ConfigurationTests: XCTestCase {
    func testWhenIChangeTheClockStyleThenTheClockStyleGetTheNewValue() {
        let store = TestStore(initialState: AppState(), reducer: appReducer, environment: .test)
        store.send(.configuration(.setClockStyle(.artNouveau))) {
            $0.configuration.clockStyle = .artNouveau
        }
        store.send(.configuration(.setClockStyle(.drawing))) {
            $0.configuration.clockStyle = .drawing
        }
        store.send(.configuration(.setClockStyle(.classic))) {
            $0.configuration.clockStyle = .classic
        }
    }

    func testWhenIWantToHideMinuteIndicatorsThenMinuteIndicatorsIsHidden() {
        let store = TestStore(initialState: AppState(), reducer: appReducer, environment: .test)
        store.send(.configuration(.setMinuteIndicatorsShown(false))) {
            $0.configuration.clock.isMinuteIndicatorsShown = false
        }
        store.send(.configuration(.setMinuteIndicatorsShown(true))) {
            $0.configuration.clock.isMinuteIndicatorsShown = true
        }
    }

    func testWhenIWantToHideHourIndicatorsThenHourIndicatorsIsHidden() {
        let store = TestStore(initialState: AppState(), reducer: appReducer, environment: .test)
        store.send(.configuration(.setHourIndicatorsShown(false))) {
            $0.configuration.clock.isHourIndicatorsShown = false
        }
        store.send(.configuration(.setHourIndicatorsShown(true))) {
            $0.configuration.clock.isHourIndicatorsShown = true
        }
    }

    func testWhenIWantToLimitHourDisplayedThenHourIsDisplayedWithALimitedAmount() {
        let store = TestStore(initialState: AppState(), reducer: appReducer, environment: .test)
        store.send(.configuration(.setLimitedHoursShown(true))) {
            $0.configuration.clock.isLimitedHoursShown = true
        }
        store.send(.configuration(.setLimitedHoursShown(false))) {
            $0.configuration.clock.isLimitedHoursShown = false
        }
    }
}
