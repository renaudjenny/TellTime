import SwiftUI

struct DrawnIndicators: View {
  var body: some View {
    Minutes()
  }
}

private struct Minutes: View {
  private static let widthRatio: CGFloat = 1/50
  private static let heightRatio: CGFloat = 1/30
  private static let marginRatio: CGFloat = 1/30

  var body: some View {
    GeometryReader { geometry in
      ForEach(1...60, id: \.self) { minute in
        DrawnIndicator()
          .rotation(Angle(degrees: Double(minute) * .minuteInDegree))
          .fill()
          .frame(
            width: geometry.localWidth * Self.widthRatio,
            height: geometry.localHeight * Self.heightRatio
          )
          .position(.pointInCircle(
            from: Angle(degrees: Double(minute) * .minuteInDegree),
            frame: geometry.localFrame,
            margin: geometry.localWidth * Self.marginRatio
          ))
      }
    }
  }
}

struct DrawnIndicator: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let radius = rect.width/2
    let bottomCenter = CGPoint(x: radius, y: rect.maxY)
    let bottomRight = CGPoint(
      x: bottomCenter.x + radius/2,
      y: bottomCenter.y
    )
    let topCenter = CGPoint(x: radius, y: radius)
    let topLeft = CGPoint(
      x: topCenter.x - radius,
      y: topCenter.y
    )

    path.move(to: bottomRight)

    path.addArc(
      center: bottomCenter,
      radius: radius/2,
      startAngle: .zero,
      endAngle: .degrees(180),
      clockwise: false
    )

    let randomLeftXControl = CGFloat.random(in: rect.minX...rect.maxX)
    let randomLeftYControl = CGFloat.random(in: rect.minY...rect.maxY)
    let controlLeft = CGPoint(
      x: randomLeftXControl,
      y: randomLeftYControl
    )
    path.addQuadCurve(to: topLeft, control: controlLeft)

    path.addArc(
      center: topCenter,
      radius: radius,
      startAngle: .degrees(180),
      endAngle: .zero,
      clockwise: false
    )

    let randomRightXControl = CGFloat.random(in: rect.minX...rect.maxX)
    let randomRightYControl = CGFloat.random(in: rect.minY...rect.maxY)
    let controlRight = CGPoint(
      x: randomRightXControl,
      y: randomRightYControl
    )
    path.addQuadCurve(to: bottomRight, control: controlRight)

    return path
  }
}

#if DEBUG
struct DrawnIndicators_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      DrawnIndicators()
        .padding()
    }
  }
}
#endif
