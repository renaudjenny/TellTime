import SwiftUI

struct DrawnArm: View {
  private static let widthRatio: CGFloat = 1/20
  let lineWidthRatio: CGFloat
  let marginRatio: CGFloat
  @State private var showIndicator = false

  var body: some View {
    GeometryReader { geometry in
      DrawnIndicator(draw: self.showIndicator)
        .frame(
          width: geometry.localWidth * Self.widthRatio * self.lineWidthRatio,
          height: self.computedHeight(geometry.localHeight)
        )
        .position(geometry.localCenter)
        .transformEffect(.init(translationX: 0, y: self.computedHeight(geometry.localHeight)/2))
        .rotationEffect(Angle(degrees: 180))
        .onAppear(perform: { self.showIndicator = true })
    }
  }

  func computedHeight(_ height: CGFloat) -> CGFloat {
    height/2 - height/2 * self.marginRatio
  }
}

#if DEBUG
struct DrawnArm_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Circle()
        .stroke()
      DrawnArm(
        lineWidthRatio: 1,
        marginRatio: 1/8
      )
    }
    .frame(width: 300, height: 300)
  }
}
#endif
