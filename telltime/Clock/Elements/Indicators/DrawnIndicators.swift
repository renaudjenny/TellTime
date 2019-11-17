import SwiftUI

struct DrawnIndicators: View {
  @EnvironmentObject var configuration: ConfigurationStore

  var body: some View {
    ZStack {
      if self.configuration.showHourIndicators {
        Hours()
      }
      if self.configuration.showMinuteIndicators {
        Minutes()
      }
    }
  }
}

private struct Hours: View {
  private static let widthRatio: CGFloat = 1/40
  private static let heightRatio: CGFloat = 1/20
  private static let marginRatio: CGFloat = 1/20

  var body: some View {
    GeometryReader { geometry in
      ForEach(1...12, id: \.self) { hour in
        DrawnIndicator()
          .rotation(Angle(degrees: Double(hour) * .hourInDegree))
          .fill()
          .frame(
            width: geometry.localWidth * Self.widthRatio,
            height: geometry.localHeight * Self.heightRatio
          )
          .position(.pointInCircle(
            from: Angle(degrees: Double(hour) * .hourInDegree),
            frame: geometry.localFrame,
            margin: geometry.localWidth * Self.marginRatio
          ))
      }
    }
  }
}

private struct Minutes: View {
  private static let widthRatio: CGFloat = 1/50
  private static let heightRatio: CGFloat = 1/30
  private static let marginRatio: CGFloat = 1/30
  @EnvironmentObject var configuration: ConfigurationStore

  var body: some View {
    GeometryReader { geometry in
      ForEach(1...60, id: \.self) { minute in
        Group {
          if self.isOverlapingHour(minute: minute) {
            EmptyView()
          } else {
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
  }

  private func isOverlapingHour(minute: Int) -> Bool {
    guard self.configuration.showHourIndicators else { return false }
    return minute == 0 || minute % 5 == 0
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
