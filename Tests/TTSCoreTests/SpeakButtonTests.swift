import SnapshotTesting
import SwiftUI
import TTSCore
import XCTest

@MainActor
class SpeakButtonTests: XCTestCase {
    func testSpeakButtons() {
        let speakButtons = SpeakButton_Previews.previews
        assertSnapshot(matching: speakButtons, as: .image(precision: 1, perceptualPrecision: 99/100))
    }
}
