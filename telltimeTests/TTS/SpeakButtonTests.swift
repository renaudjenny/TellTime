import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class SpeakButtonTests: XCTestCase {
    func testSpeakButtons() {
        let speakButtons = SpeakButton_Previews.previews
        assertSnapshot(matching: speakButtons, as: .image(layout: .device(config: .iPhoneSe)))
    }
}
