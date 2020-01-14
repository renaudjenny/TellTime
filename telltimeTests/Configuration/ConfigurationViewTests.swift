import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class ConfigurationViewTests: XCTestCase {
  func testConfigurationViews() {
    Current.isAnimationDisabled = true
    let configurationViews = ConfigurationView_Previews.previews
    let hostingController = UIHostingController(rootView: configurationViews)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
