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
      DrawnNumbers()
    }
    .animation(.easeOut)
  }
}

private struct Hours: View {
  private static let widthRatio: CGFloat = 1/40
  private static let heightRatio: CGFloat = 1/20
  private static let marginRatio: CGFloat = 1/20
  @State private var animate: Bool = false

  var body: some View {
    GeometryReader { geometry in
      ForEach(1...12, id: \.self) { hour in
        DrawnIndicator(draw: self.animate)
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
          .onAppear(perform: { self.animate = true })
      }
    }
  }
}

private struct Minutes: View {
  private static let widthRatio: CGFloat = 1/50
  private static let heightRatio: CGFloat = 1/30
  private static let marginRatio: CGFloat = 1/30
  @EnvironmentObject var configuration: ConfigurationStore
  @State private var animate: Bool = false

  var body: some View {
    GeometryReader { geometry in
      ForEach(1...60, id: \.self) { minute in
        Group {
          if self.isOverlapingHour(minute: minute) {
            EmptyView()
          } else {
            DrawnIndicator(draw: self.animate)
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
              .onAppear(perform: { self.animate = true })
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
  private var drawStep: CGFloat
  private let randomLeftXControlRatio = CGFloat.random(in: 0.1...1)
  private let randomLeftYControlRatio = CGFloat.random(in: 0.1...1)
  private let randomRightXControlRatio = CGFloat.random(in: 0.1...1)
  private let randomRightYControlRatio = CGFloat.random(in: 0.1...1)

  init(draw: Bool) {
    self.drawStep = draw ? 1 : 0
  }

  var animatableData: CGFloat {
    get { self.drawStep }
    set { self.drawStep = newValue }
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let radius = rect.width/2 * self.drawStep
    let bottomCenter = CGPoint(x: radius, y: rect.maxY * self.drawStep)
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

    let controlLeft = CGPoint(
      x: rect.maxX * self.randomLeftXControlRatio,
      y: rect.maxY * self.randomLeftYControlRatio
    )
    path.addQuadCurve(to: topLeft, control: controlLeft)

    path.addArc(
      center: topCenter,
      radius: radius,
      startAngle: .degrees(180),
      endAngle: .zero,
      clockwise: false
    )

    let controlRight = CGPoint(
      x: rect.maxX * self.randomRightXControlRatio,
      y: rect.maxY * self.randomRightYControlRatio
    )
    path.addQuadCurve(to: bottomRight, control: controlRight)

    return path
  }
}

struct DrawnNumbers: View {
  private static let hours = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  private static let limitedHours = [12, 3, 6, 9]
  private static let marginRatio: CGFloat = 1/7
  private static let availableRotationAngles: [Angle] = [.zero, .degrees(-5), .degrees(5)]
  private static let availableScale: [CGFloat] = [1, 1.1, 0.9]
  @EnvironmentObject var configuration: ConfigurationStore

  var body: some View {
    GeometryReader { geometry in
      ForEach(self.configurationHours, id: \.self) { hour in
        Text("\(hour)")
          .rotationEffect(Self.availableRotationAngles.randomElement() ?? .zero, anchor: .center)
          .scaleEffect(Self.availableScale.randomElement() ?? 1, anchor: .center)
          .position(.pointInCircle(
            from: Angle(degrees: Double(hour) * .hourInDegree),
            frame: geometry.localFrame,
            margin: geometry.localWidth * self.marginRatio
          ))
      }
    }
  }

  private var marginRatio: CGFloat {
    self.configuration.showIndicators ? Self.marginRatio : Self.marginRatio/2
  }

  private var configurationHours: [Int] {
    self.configuration.showLimitedHourIndicators ? Self.limitedHours : Self.hours
  }
}

#if DEBUG
struct DrawnIndicators_Previews: PreviewProvider {
  static var previews: some View {
    DrawnIndicators()
  }
}
#endif
