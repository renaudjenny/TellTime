// See Achieving maximum test readability at no cost for iOS
// https://medium.com/flawless-app-stories/ios-achieving-maximum-test-readability-at-no-cost-906af0dbaa98

import XCTest
import os.log

func given<Result>(_ description: String, block: () throws -> Result) rethrows -> Result {
    os_log("1º Given %{public}@", description)
    return try XCTContext.runActivity(named: "Given " + description, block: { _ in try block() })
}

func when<Result>(_ description: String, block: () throws -> Result) rethrows -> Result {
    os_log("2º When %{public}@", description)
    return try XCTContext.runActivity(named: "When " + description, block: { _ in try block() })
}

func then<Result>(_ description: String, block: () throws -> Result) rethrows -> Result {
    os_log("3º Then %{public}@", description)
    return try XCTContext.runActivity(named: "Then " + description, block: { _ in try block() })
}
