import SwiftUI
import Combine

struct WatchPointers: View {
  var body: some View {
    ZStack {
      WatchPointer(type: .hour)
      WatchPointer(type: .minute)
    }
  }
}

#if DEBUG
struct WatchPointers_Previews: PreviewProvider {
  static var previews: some View {
    WatchPointers()
  }
}
#endif
