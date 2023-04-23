import AppFeature
import SwiftUI

@main
struct TellTimeUKApp: SwiftUI.App {

    var body: some Scene {
        WindowGroup {
            AppView(store: .live)
        }
    }
}
