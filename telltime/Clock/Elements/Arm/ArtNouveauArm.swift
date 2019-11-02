import SwiftUI

struct ArtNouveauArm: View {
  let lineWidthRatio: CGFloat
  let marginRatio: CGFloat
  private static let widthRatio: CGFloat = 1/50

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        let center = geometry.localCenter
        let width = geometry.localWidth * Self.widthRatio * self.lineWidthRatio
        let top = center.y * self.marginRatio
        let height = center.y - top

        path.addArc(
          center: center,
          radius: width,
          startAngle: .zero,
          endAngle: .degrees(180),
          clockwise: false
        )

        let peak = CGPoint(x: center.x, y: top)

        let destination = peak.applying(.init(translationX: -width/2, y: 0))
        let peakControl1 = CGPoint(x: center.x + width * 2, y: top + height * 3/4)
        let peakControl2 = CGPoint(x: center.x - width * 3, y: top + height * 1/5)

        path.addCurve(
          to: destination,
          control1: peakControl1,
          control2: peakControl2
        )

        path.addArc(
          center: peak,
          radius: width/2,
          startAngle: .degrees(180),
          endAngle: .zero,
          clockwise: false
        )

        let arrival = center.applying(.init(translationX: width, y: 0))
        let arrivalControl1 = CGPoint(x: center.x - width * 2, y: top + height * 1/5)
        let arrivalControl2 = CGPoint(x: center.x + width * 3, y: top + height * 3/4)

        path.addCurve(
          to: arrival,
          control1: arrivalControl1,
          control2: arrivalControl2
        )
      }
    }
  }
}

struct ArtNouveauArm_Previews: PreviewProvider {
  static var previews: some View {
    ArtNouveauArm(
      lineWidthRatio: 1,
      marginRatio: 1/8
    )
  }
}
