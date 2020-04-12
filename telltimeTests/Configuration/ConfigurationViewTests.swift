import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class ConfigurationViewTests: XCTestCase {
    func testConfigurationViews() {
        let configurationViews = ConfigurationView_Previews.previews
            .environment(\.clockIsAnimationEnabled, false)
        let hostingController = UIHostingController(rootView: configurationViews)
        assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe))
    }
    
    func testConfigurationViewsInLandscape() {
        let configurationViews = ConfigurationViewLandscape_Previews.previews
            .environment(\.clockIsAnimationEnabled, false)
        let hostingController = UIHostingController(rootView: configurationViews)
        assertSnapshot(matching: hostingController, as: .image(on: .iPhoneSe(.landscape)))
    }
}
