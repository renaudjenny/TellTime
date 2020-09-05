import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class AboutViewTests: XCTestCase {
    func testAboutViews() {
        let aboutViews = AboutView_Previews.previews
        assertSnapshot(
            matching: aboutViews,
            as: .defaultImage
        )
    }
}
