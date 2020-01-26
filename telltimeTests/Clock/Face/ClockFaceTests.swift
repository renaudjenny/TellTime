import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class ClockFaceTests: XCTestCase {
  func testClockFaceSmiling() {
    let clockFaces = ClockFaceSmiling_Previews.previews
    let hostingController = UIHostingController(rootView: clockFaces)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }

  func testClockFaceNeutral() {
    let clockFaces = ClockFaceNeutral_Previews.previews
    let hostingController = UIHostingController(rootView: clockFaces)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }
}
