import SwiftUI
import Combine

struct Arms: View {
  var body: some View {
    ZStack {
      ArmContainer(type: .hour)
      ArmContainer(type: .minute)
    }
  }
}

#if DEBUG
struct Arms_Previews: PreviewProvider {
  static var previews: some View {
    Arms()
      .environmentObject(App.previewStore)
  }
}
#endif
