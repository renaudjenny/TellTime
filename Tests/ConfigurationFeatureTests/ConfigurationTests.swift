import ComposableArchitecture
import ConfigurationFeature
import XCTest

@MainActor
class ConfigurationTests: XCTestCase {
    func testClockStyleChanged() async {
        let store = TestStore(initialState: Configuration.State(), reducer: Configuration())
        await store.send(.set(\.$clockStyle, .artNouveau)) {
            $0.clockStyle = .artNouveau
        }
        await store.send(.set(\.$clockStyle, .drawing)) {
            $0.clockStyle = .drawing
        }
        await store.send(.set(\.$clockStyle, .steampunk)) {
            $0.clockStyle = .steampunk
        }
        await store.send(.set(\.$clockStyle, .classic)) {
            $0.clockStyle = .classic
        }
    }

    func testMinuteIndicatorChanged() async {
        let store = TestStore(initialState: Configuration.State(), reducer: Configuration())
        await store.send(.set(\.$clock.isMinuteIndicatorsShown, false)) {
            $0.clock.isMinuteIndicatorsShown = false
        }
        await store.send(.set(\.$clock.isMinuteIndicatorsShown, true)) {
            $0.clock.isMinuteIndicatorsShown = true
        }
    }

    func testHourIndicatorChanged() async {
        let store = TestStore(initialState: Configuration.State(), reducer: Configuration())
        await store.send(.set(\.$clock.isHourIndicatorsShown, false)) {
            $0.clock.isHourIndicatorsShown = false
        }
        await store.send(.set(\.$clock.isHourIndicatorsShown, true)) {
            $0.clock.isHourIndicatorsShown = true
        }
    }

    func testLimitHourDisplayedChanged() async {
        let store = TestStore(initialState: Configuration.State(), reducer: Configuration())
        await store.send(.set(\.$clock.isLimitedHoursShown, true)) {
            $0.clock.isLimitedHoursShown = true
        }
        await store.send(.set(\.$clock.isLimitedHoursShown, false)) {
            $0.clock.isLimitedHoursShown = false
        }
    }
}
