import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class ClockBordersTests: XCTestCase {
  func testClockBorders() {
    Current.isAnimationDisabled = true
    Current.clock.drawnRandomBorderMarginRatio = (
      maxMargin: { $0 },
      angleMargin: { 1/3 }
    )
    let borders = ClockBorder_Previews.previews
    let hostingController = UIHostingController(rootView: borders)
    assertSnapshot(matching: hostingController, as: .image)
  }

  func testClassicClockBorders() {
    let borders = ClassicClockBorder_Previews.previews
    let hostingController = UIHostingController(rootView: borders)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
