import SwiftUI

struct ArtNouveauClockBorder: View {
  static let borderWidthRatio: CGFloat = 1/100
  static let innerCircleScale: CGFloat = 9/10
  let localWidth: CGFloat

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .stroke(lineWidth: self.localWidth * Self.borderWidthRatio)
        Circle()
          .scale(Self.innerCircleScale)
          .transform(.init(
            translationX: 0,
            y: geometry.localDiameter/2 * (1 - Self.innerCircleScale)
          ))
          .stroke(lineWidth: self.localWidth * Self.borderWidthRatio/4)
      }
    }
  }
}

#if DEBUG
struct ArtNouveauClockBorderClockBorder_Previews: PreviewProvider {
  static var previews: some View {
    ArtNouveauClockBorder(localWidth: 300)
  }
}
#endif
