import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class ClockFaceTests: XCTestCase {
  func testClockFaces() {
    let clockFaces = ClockFace_Previews.previews
    let hostingController = UIHostingController(rootView: clockFaces)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
