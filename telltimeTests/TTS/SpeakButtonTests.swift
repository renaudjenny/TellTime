import XCTest
@testable import Tell_Time_UK
import SnapshotTesting
import SwiftUI

class SpeakButtonTests: XCTestCase {
  func testSpeakButtons() {
    Current.isAnimationDisabled = true
    let speakButtons = SpeakButton_Previews.previews
    let hostingController = UIHostingController(rootView: speakButtons)
    assertSnapshot(matching: hostingController, as: .image)
  }
}
