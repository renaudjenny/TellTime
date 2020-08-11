import XCTest
@testable import Tell_Time_UK
import SwiftUI
import Combine
import SwiftTTSCombine
import AVFoundation

typealias App = Tell_Time_UK.App

class TelltimeTests: XCTestCase {
    func testWhenIStartTheApplicationThenTheStoreDateIsTheCurrentOne() {
        let fakeCurrentDate = Date(timeIntervalSince1970: 4300)
        let fakeEnvironment: App.Environment = .fake(currentDate: fakeCurrentDate)

        let store = Store<App.State, App.Action, App.Environment>(
            initialState: App.State(date: fakeCurrentDate),
            reducer: App.reducer,
            environment: fakeEnvironment
        )

        let tellTime = EnvironmentValues().tellTime
        XCTAssertEqual(tellTime(store.state.date, .test), "It's one eleven AM.")
    }

    func testWhenIChangedTheDateThenICanReadLiteralTimeFromIt() {
        let fakeCurrentDate = Date(timeIntervalSince1970: 4360)

        let store = App.testStore
        store.send(.changeDate(fakeCurrentDate))

        let tellTime = EnvironmentValues().tellTime
        XCTAssertEqual(tellTime(store.state.date, .test), "It's one twelve AM.")
    }
}

extension App {
    static func testStore(
        modifyState: (inout App.State) -> Void = { _ in },
        environment: Environment = .fake
    ) -> Store<App.State, App.Action, Environment> {
        var state = App.State(date: environment.currentDate())
        _ = modifyState(&state)
        return .init(initialState: state, reducer: App.reducer, environment: environment)
    }

    static var testStore: Store<App.State, App.Action, Environment> { testStore() }
}

extension App.Environment {
    static var fake: Self {
        fake(currentDate: Date(hour: 10, minute: 10, calendar: .test))
    }

    static func fake(currentDate: Date) -> Self {
        Self(
            currentDate: { currentDate },
            tts: .fake
        )
    }
}

extension TTS.Environment {
    static var fake: Self {
        TTS.Environment(
            engine: MockedTTSEngine(),
            calendar: .test,
            tellTime: { _, _ in "12:34" }
        )
    }

    private final class MockedTTSEngine: TTSEngine {
        var rateRatio: Float = 1.0
        var voice: AVSpeechSynthesisVoice?
        func speak(string: String) { }
        var isSpeakingPublisher: AnyPublisher<Bool, Never> { Just(false).eraseToAnyPublisher() }
        var speakingProgressPublisher: AnyPublisher<Double, Never> { Just(0.0).eraseToAnyPublisher() }
    }
}
