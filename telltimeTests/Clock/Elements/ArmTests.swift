import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class ArmTests: XCTestCase {
  func testArms() {
    Current.isAnimationDisabled = true
    Current.clock.drawnRandomControlRatio = (
      leftX: { 0.5 },
      leftY: { 0.6 },
      rightX: { 0.7 },
      rightY: { 0.8 }
    )
    let arms = Arm_Previews.previews
    let hostingController = UIHostingController(rootView: arms)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
