import XCTest
@testable import telltime

class ConfigurationTests: XCTestCase {
  func testDefaultConfigurationValues() {
    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    XCTAssertEqual(store.state.configuration.clockStyle, .classic)
    XCTAssertEqual(store.state.configuration.isMinuteIndicatorsShown, true)
    XCTAssertEqual(store.state.configuration.isHourIndicatorsShown, true)
    XCTAssertEqual(store.state.configuration.isLimitedHoursShown, false)
  }
}
