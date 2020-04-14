import SwiftUI
import Combine
import SwiftClockUI

struct RootView: View {
    var body: some View {
        NavigationView {
            TellTimeView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
