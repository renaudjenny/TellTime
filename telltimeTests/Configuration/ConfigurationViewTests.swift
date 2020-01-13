import XCTest
@testable import telltime
import SnapshotTesting
import SwiftUI

class ConfigurationViewTests: XCTestCase {
  func testConfigurationViews() {
    Current.isOnAppearAnimationDisabled = true
    let configurationViews = ConfigurationView_Previews.previews
    let hostingController = UIHostingController(rootView: configurationViews)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
