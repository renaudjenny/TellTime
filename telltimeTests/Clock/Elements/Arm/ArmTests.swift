import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class ArmTests: XCTestCase {
  func testArms() {
    let arms = Arm_Previews.previews
    let hostingController = UIHostingController(rootView: arms)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
