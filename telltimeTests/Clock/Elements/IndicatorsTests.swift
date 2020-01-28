import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class IndicatorsTests: XCTestCase {
  func testIndicators() {
    Current.isAnimationDisabled = true
    Current.clock.randomControlRatio = (
      leftX: { 0.5 },
      leftY: { 0.6 },
      rightX: { 0.7 },
      rightY: { 0.8 }
    )
    Current.clock.randomAngle = { .degrees(5) }
    Current.clock.randomScale = { 1 }
    let indicators = Indicators_Previews.previews
    let hostingController = UIHostingController(rootView: indicators)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
