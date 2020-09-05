import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class ConfigurationViewTests: XCTestCase {
    func testConfigurationViews() {
        let configurationViews = ConfigurationView_Previews.previews
            .environment(\.clockIsAnimationEnabled, false)
        assertSnapshot(matching: configurationViews, as: .defaultImage)
    }

    func testConfigurationViewsInLandscape() {
        let configurationViews = ConfigurationViewLandscape_Previews.previews
            .environment(\.clockIsAnimationEnabled, false)
        assertSnapshot(matching: configurationViews, as: .image(layout: .device(config: .iPhoneSe(.landscape))))
    }
}
