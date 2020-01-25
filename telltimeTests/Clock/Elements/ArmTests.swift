import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class ArmTests: XCTestCase {
  func testArms() {
    Current.isAnimationDisabled = true
    Current.clock.randomControlRatio = (
      leftX: { 0.5 },
      leftY: { 0.6 },
      rightX: { 0.7 },
      rightY: { 0.8 }
    )
    let arms = Arm_Previews.previews
    let hostingController = UIHostingController(rootView: arms)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }

  func testBiggerArm() {
    Current.isAnimationDisabled = true
    Current.clock.randomControlRatio = (
      leftX: { 0.5 },
      leftY: { 0.6 },
      rightX: { 0.7 },
      rightY: { 0.8 }
    )
    let arms = BiggerArm_Previews.previews
    let hostingController = UIHostingController(rootView: arms)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }

  func testArmWithAnAngle() {
    Current.isAnimationDisabled = true
    Current.clock.randomControlRatio = (
      leftX: { 0.5 },
      leftY: { 0.6 },
      rightX: { 0.7 },
      rightY: { 0.8 }
    )
    let arms = ArmWithAnAngle_Previews.previews
    let hostingController = UIHostingController(rootView: arms)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }

  func testArtNouveauArm() {
    Current.isAnimationDisabled = true
    Current.clock.randomControlRatio = (
      leftX: { 0.5 },
      leftY: { 0.6 },
      rightX: { 0.7 },
      rightY: { 0.8 }
    )
    let arms = ArtNouveauDesignArm_Previews.previews
    let hostingController = UIHostingController(rootView: arms)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }

  func testDrawningArm() {
    Current.isAnimationDisabled = true
    Current.clock.randomControlRatio = (
      leftX: { 0.5 },
      leftY: { 0.6 },
      rightX: { 0.7 },
      rightY: { 0.8 }
    )
    let arms = DrawingDesignArm_Previews.previews
    let hostingController = UIHostingController(rootView: arms)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }

  func testDrawnArms() {
    Current.isAnimationDisabled = true
    Current.clock.randomControlRatio = (
      leftX: { 0.5 },
      leftY: { 0.6 },
      rightX: { 0.7 },
      rightY: { 0.8 }
    )
    let arms = DrawnArm_Previews.previews
    let hostingController = UIHostingController(rootView: arms)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }
}
