import ConfigurationFeature
import SnapshotTesting
import SwiftUI
import XCTest

class ConfigurationViewTests: XCTestCase {
    func testConfigurationViews() {
        let configurationViews = ConfigurationView_Previews.previews
        assertSnapshot(matching: configurationViews, as: .image(layout: .fixed(width: 320, height: 568)))
    }

    func testConfigurationViewsInLandscape() {
        let configurationViews = ConfigurationView_Previews.previews
        assertSnapshot(matching: configurationViews, as: .image(layout: .fixed(width: 568, height: 320)))
    }
}
