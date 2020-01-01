import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class MouthTests: XCTestCase {
  func testMouthNeutral() {
    let mouths = Mouth_Previews.previews
    let hostingController = UIHostingController(rootView: mouths)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
