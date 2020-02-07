import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class ClockBordersTests: XCTestCase {
  func testClassicClockBorders() {
    let borders = ClassicClockBorder_Previews.previews
    let hostingController = UIHostingController(rootView: borders)
    assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
  }
}
