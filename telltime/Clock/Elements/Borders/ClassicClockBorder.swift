import SwiftUI

struct ClassicClockBorder: View {
  static let borderWidthRatio: CGFloat = 1/70
  let localWidth: CGFloat

  var body: some View {
    Circle()
      .stroke(lineWidth: self.localWidth * Self.borderWidthRatio)
  }
}

#if DEBUG
struct ClassicClockBorder_Previews: PreviewProvider {
  static var previews: some View {
    ClassicClockBorder(localWidth: 300)
  }
}
#endif
