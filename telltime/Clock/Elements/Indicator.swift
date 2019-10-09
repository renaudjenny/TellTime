import SwiftUI

struct Indicators: View {
  private let margin: CGFloat = 16.0

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .center) {
        Text("12")
          .position(x: geometry.localCenter.x, y: geometry.localTop + self.margin)
        Text("3")
          .position(x: geometry.localWidth - self.margin, y: geometry.localCenter.y)
        Text("6")
          .position(x: geometry.localCenter.x, y: geometry.localBottom - self.margin)
        Text("9")
          .position(x: geometry.localLeft + self.margin, y: geometry.localCenter.y)
      }
    }
  }
}

#if DEBUG
struct Indicators_Previews: PreviewProvider {
  static var previews: some View {
    Indicators()
  }
}
#endif
