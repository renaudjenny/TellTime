import SwiftUI

struct ArtNouveauClockBorder: View {
  static let borderWidthRatio: CGFloat = 1/100
  let localWidth: CGFloat

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .stroke(lineWidth: self.localWidth * Self.borderWidthRatio)
        Circle()
          .scale(0.90)
          .transform(.init(
            translationX: 0,
            y: geometry.localWidth/2 * (1 - 0.90)
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
