import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class EyeTests: XCTestCase {
  func testEyes() {
    let eyes = Eye_Previews.previews
    let hostingController = UIHostingController(rootView: eyes)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
