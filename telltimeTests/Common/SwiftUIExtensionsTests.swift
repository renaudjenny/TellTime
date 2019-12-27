import XCTest
@testable import telltime
import SwiftUI

class SwiftUIExtensionsTests: XCTestCase {

  func testDoubleExtension() {
    XCTAssertEqual(50.0, 50.0.positiveDegrees)
    XCTAssertEqual(310.0, (-50.0).positiveDegrees)

    XCTAssertEqual(Double.pi, Double.pi.positiveRadians)
    XCTAssertEqual(Double.pi, (-Double.pi).positiveRadians)
  }
}
