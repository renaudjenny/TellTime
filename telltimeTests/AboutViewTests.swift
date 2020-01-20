import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class AboutViewTests: XCTestCase {
  func testAboutViews() {
    let aboutViews = AboutView_Previews.previews
    let hostingController = UIHostingController(rootView: aboutViews)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
