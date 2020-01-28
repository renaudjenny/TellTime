import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class MouthTests: XCTestCase {
  func testMouths() {
    let mouths = Mouth_Previews.previews
    let hostingController = UIHostingController(rootView: mouths)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
