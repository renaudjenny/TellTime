import SwiftUI

struct Clock: View {
  static let borderWidthRatio: CGFloat = 1/70
  @EnvironmentObject var clock: ClockStore

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ClockBorder(localWidth: geometry.localWidth)
        Indicators()
        Arms()
        ClockFace()
          .opacity(self.clock.showClockFace ? 1 : 0)
          .animation(.easeInOut)
      }
      .frame(width: geometry.localDiameter, height: geometry.localDiameter)
      .fixedSize()
    }
    .frame(maxWidth: 500, maxHeight: 500)
  }
}

#if DEBUG
struct Clock_Previews: PreviewProvider {
  static var previews: some View {
    return Clock()
  }
}
#endif
