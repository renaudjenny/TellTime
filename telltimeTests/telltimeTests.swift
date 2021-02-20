import XCTest
@testable import Tell_Time_UK
import SwiftUI
import Combine
import ComposableArchitecture
import SwiftTTSCombine
import Speech
import AVFoundation

class TelltimeTests: XCTestCase {
    func testWhenIStartTheApplicationThenTheStoreDateIsTheCurrentOne() {
        let fakeCurrentDate = Date(timeIntervalSince1970: 4300)
        XCTAssertEqual(tellTime(date: fakeCurrentDate, calendar: .test), "It's one eleven AM.")
    }

    func testWhenIChangedTheDateThenICanReadLiteralTimeFromIt() {
        let fakeCurrentDate = Date(timeIntervalSince1970: 4360)

        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: .test {
                $0.tellTime = tellTime
                $0.calendar = .test
            }
        )
        store.assert(
            .send(.setDate(fakeCurrentDate)) {
                $0.date = fakeCurrentDate
                $0.tellTime = "It's one twelve AM."
            }
        )
    }
}
