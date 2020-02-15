import SwiftUI

struct DrawnArm: View {
  private static let widthRatio: CGFloat = 1/20
    let type: ArmType
  @State private var showIndicator = false

  var body: some View {
    DrawnArmShape(draw: self.showIndicator, type: type)
      .onAppear(perform: { self.showIndicator = true })
  }
}

private struct DrawnArmShape: Shape {
    private static let widthRatio: CGFloat = 1/30
    let type: ArmType
    private var drawStep: CGFloat
    private static var controlRatios = DrawnControlRatios()

    init(draw: Bool, type: ArmType) {
        self.drawStep = draw || Current.isAnimationDisabled ? 1 : 0.1
        self.type = type
        self.generateControlRatiosIfNeeded()
    }

    var animatableData: CGFloat {
        get { self.drawStep }
        set { self.drawStep = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let diameter = min(rect.height, rect.width)
        let width = diameter * Self.widthRatio * type.ratio.lineWidth
        let margin = diameter/2 * type.ratio.margin
        let bottomRight = CGPoint(
            x: center.x + width/2,
            y: center.y
        )

        let topY = center.y - diameter/2 * self.drawStep
        let topCenter = CGPoint(x: diameter/2, y: topY + margin + width/2)
        let topLeft = CGPoint(
            x: topCenter.x - width/2,
            y: topCenter.y
        )

        path.move(to: bottomRight)

        path.addArc(
            center: center,
            radius: width/2,
            startAngle: .zero,
            endAngle: .degrees(180),
            clockwise: false
        )

        let controlLeft = CGPoint(
            x: diameter/2 - width/2 *  Self.controlRatios.leftX,
            y: topY + width/2 + diameter/2 * Self.controlRatios.leftY
        )

        path.addQuadCurve(to: topLeft, control: controlLeft)

        path.addArc(
            center: topCenter,
            radius: width/2,
            startAngle: .degrees(180),
            endAngle: .zero,
            clockwise: false
        )

        let controlRight = CGPoint(
            x: diameter/2 + width/2 *  Self.controlRatios.rightX,
            y: topY + width/2 + diameter/2 * Self.controlRatios.rightY
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
            Circle().stroke()
            DrawnArm(type: .minute)
        }
        .padding()
    }
}
#endif
