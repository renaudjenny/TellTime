import SwiftUI

struct DrawnArm: View {
  private static let widthRatio: CGFloat = 1/20
  let lineWidthRatio: CGFloat
  let marginRatio: CGFloat
  @State private var showIndicator = false

  var body: some View {
    DrawnArmShape(
      draw: self.showIndicator,
      lineWidthRatio: self.lineWidthRatio,
      marginRatio: self.marginRatio
    )
      .onAppear(perform: { self.showIndicator = true })
  }
}

private struct DrawnArmShape: Shape {
  private static let bottomRatio: CGFloat = 1/20
  private static let topRatio: CGFloat = 1/40
  let lineWidthRatio: CGFloat
  let marginRatio: CGFloat
  private var drawStep: CGFloat
  private static var controlRatios = DrawnControlRatios()

  init(draw: Bool, lineWidthRatio: CGFloat, marginRatio: CGFloat) {
    self.drawStep = draw || Current.isAnimationDisabled ? 1 : 0
    self.lineWidthRatio = lineWidthRatio
    self.marginRatio = marginRatio
    self.generateControlRatiosIfNeeded()
  }

  var animatableData: CGFloat {
    get { self.drawStep }
    set { self.drawStep = newValue }
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let radius = min(rect.height, rect.width)/2
    let bottomCenter = CGPoint(x: radius, y: rect.maxY/2)
    let bottomRadius = radius * self.lineWidthRatio * Self.bottomRatio
    let bottomRight = CGPoint(
      x: bottomCenter.x + bottomRadius,
      y: bottomCenter.y
    )
    let topRadius = radius * self.lineWidthRatio * Self.topRatio
    let topMargin = rect.maxY/2 * self.marginRatio
    let topY = rect.maxY/2 * (1 - self.drawStep)
    let topCenter = CGPoint(x: radius, y: topY + topMargin + topRadius)
    let topLeft = CGPoint(
      x: topCenter.x - topRadius,
      y: topCenter.y
    )

    path.move(to: bottomRight)

    path.addArc(
      center: bottomCenter,
      radius: bottomRadius,
      startAngle: .zero,
      endAngle: .degrees(180),
      clockwise: false
    )

    let controlLeft = CGPoint(
      x: rect.maxX/2 - bottomRadius * Self.controlRatios.leftX,
      y: topCenter.y + rect.maxY/16 + rect.maxY/4 * Self.controlRatios.leftY
    )
    path.addQuadCurve(to: topLeft, control: controlLeft)

    path.addArc(
      center: topCenter,
      radius: topRadius,
      startAngle: .degrees(180),
      endAngle: .zero,
      clockwise: false
    )

    let controlRight = CGPoint(
      x: rect.maxX/2 + bottomRadius * Self.controlRatios.rightX,
      y: topCenter.y + rect.maxY/16 + rect.maxY/4 * Self.controlRatios.rightY
    )
    path.addQuadCurve(to: bottomRight, control: controlRight)

    return path
  }

  func generateControlRatiosIfNeeded() {
    if self.drawStep <= 0 {
      Self.controlRatios = DrawnControlRatios()
    }
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
    .previewDevice("iPhone SE")
    .previewDisplayName("Drawn Arm")
  }
}
#endif
