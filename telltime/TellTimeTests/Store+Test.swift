@testable import Tell_Time_UK
import Combine
import ComposableArchitecture
import AVFoundation
import Speech

extension AppEnvironment {
    static func test(
        modifyEnvironment: (inout AppEnvironment) -> Void = { _ in }
    ) -> Self {
        let environment: AppEnvironment = .preview(modifyEnvironment: modifyEnvironment)
        return environment
    }

    static var test: Self { .test() }
}
