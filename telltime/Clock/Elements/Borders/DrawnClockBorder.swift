import SwiftUI

struct DrawnClockBorder: View {
  static let borderWidthRatio: CGFloat = 1/70
  let localWidth: CGFloat

  var body: some View {
    DrawnCircle()
      .stroke(lineWidth: self.localWidth * Self.borderWidthRatio)
  }
}

struct DrawnCircle: Shape {
  private static let marginRatio: CGFloat = 1/80
  private static let numberOfArcs = 26
  private static let angleRatio: Double = 360/Double(Self.numberOfArcs - 1)

  func path(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: .pointInCircle(from: .zero, frame: rect))

    let margin = rect.width * Self.marginRatio
    for i in 1...Self.numberOfArcs {
      let angle = Angle(degrees: Double(i) * Self.angleRatio)
      let to: CGPoint = .pointInCircle(
        from: angle,
        frame: rect,
        margin: CGFloat.random(in: 0...margin)
      )

      let control: CGPoint = .pointInCircle(
        from: Angle(degrees: angle.degrees - Double.random(in: 0...1/3) * Self.angleRatio),
        frame: rect,
        margin: margin
      )
      path.addQuadCurve(to: to, control: control)
    }

    return path
  }
}

#if DEBUG
struct DrawnClockBorder_Previews: PreviewProvider {
  static var previews: some View {
    DrawnClockBorder(localWidth: 300)
    .padding()
  }
}
#endif
