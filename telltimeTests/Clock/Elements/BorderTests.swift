import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class ClockBordersTests: XCTestCase {
  func testClockBorders() {
    Current.isAnimationDisabled = true
    Current.clock.randomBorderMarginRatio = (
      maxMargin: { $0 },
      angleMargin: { 1/3 }
    )
    let borders = ClockBorder_Previews.previews
    let hostingController = UIHostingController(rootView: borders)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }

  func testClassicClockBorders() {
    let borders = ClassicClockBorder_Previews.previews
    let hostingController = UIHostingController(rootView: borders)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }
}
