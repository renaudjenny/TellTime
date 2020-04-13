import XCTest
@testable import Tell_Time_UK

class TelltimeTests: XCTestCase {
    func testWhenIStartTheApplicationThenTheStoreDateIsTheCurrentOne() {
        let fakeCurrentDate = Date(timeIntervalSince1970: 4300)
        let fakeEnvironment = App.Environment(currentDate: { fakeCurrentDate })

        let store = Store<App.State, App.Action, App.Environment>(
            initialState: App.State(date: fakeCurrentDate),
            reducer: App.reducer,
            environment: fakeEnvironment
        )

        XCTAssertEqual(Current.tellTime(store.state.date, .test), "It's one eleven AM.")
    }

    func testWhenIChangedTheDateThenICanReadLiteralTimeFromIt() {
        let fakeCurrentDate = Date(timeIntervalSince1970: 4360)

        let store = App.testStore
        store.send(.changeDate(fakeCurrentDate))

        XCTAssertEqual(Current.tellTime(store.state.date, .test), "It's one twelve AM.")
    }
}

extension App {
    static func testStore(
        modifyState: (inout App.State) -> Void
    ) -> Store<App.State, App.Action, Environment> {
        let mockedEnvironment = Environment(currentDate: {
            Date(hour: 10, minute: 10, calendar: .test)
        })
        var state = App.State(date: mockedEnvironment.currentDate())
        _ = modifyState(&state)
        return .init(initialState: state, reducer: App.reducer, environment: mockedEnvironment)
    }

    static var testStore: Store<App.State, App.Action, Environment> { App.testStore { _ in } }
}
