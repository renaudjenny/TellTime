import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class EyeTests: XCTestCase {
  func testEyes() {
    let eyes = Eye_Previews.previews
    let hostingController = UIHostingController(rootView: eyes)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
