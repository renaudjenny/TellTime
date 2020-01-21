import SwiftUI

struct DrawnIndicatorsContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>

  var body: some View {
    DrawnIndicators(
      isHourIndicatorsShown: self.store.state.configuration.isHourIndicatorsShown,
      isMinuteIndicatorsShown: self.store.state.configuration.isMinuteIndicatorsShown,
      isLimitedHoursShown: self.store.state.configuration.isLimitedHoursShown
    )
  }
}

struct DrawnIndicators: View {
  let isHourIndicatorsShown: Bool
  let isMinuteIndicatorsShown: Bool
  let isLimitedHoursShown: Bool

  var body: some View {
    ZStack {
      if self.isHourIndicatorsShown {
        Hours()
      }
      if self.isMinuteIndicatorsShown {
        Minutes(isHourIndicatorsShown: self.isHourIndicatorsShown)
      }
      DrawnNumbers(
        isHourIndicatorsShown: self.isHourIndicatorsShown,
        isMinuteIndicatorsShown: self.isMinuteIndicatorsShown,
        isLimitedHoursShown: self.isLimitedHoursShown
      )
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
  let isHourIndicatorsShown: Bool
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
    guard self.isHourIndicatorsShown else { return false }
    return minute == 0 || minute % 5 == 0
  }
}

struct DrawnIndicator: Shape {
  private var drawStep: CGFloat
  private var controlRatios = ControlRatios()

  init(draw: Bool) {
    self.drawStep = draw || Current.isAnimationDisabled ? 1 : 0
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
      x: rect.maxX * self.controlRatios.leftX,
      y: rect.maxY * self.controlRatios.leftY
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
      x: rect.maxX * self.controlRatios.rightX,
      y: rect.maxY * self.controlRatios.rightY
    )
    path.addQuadCurve(to: bottomRight, control: controlRight)

    return path
  }

  private struct ControlRatios {
    let leftX = Current.clock.randomControlRatio.leftX()
    let leftY = Current.clock.randomControlRatio.leftY()
    let rightX = Current.clock.randomControlRatio.rightX()
    let rightY = Current.clock.randomControlRatio.rightY()
  }
}

struct DrawnNumbers: View {
  private static let hours = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  private static let limitedHours = [12, 3, 6, 9]
  private static let marginRatio: CGFloat = 1/7
  let isHourIndicatorsShown: Bool
  let isMinuteIndicatorsShown: Bool
  let isLimitedHoursShown: Bool

  var body: some View {
    GeometryReader { geometry in
      ForEach(self.configurationHours, id: \.self) { hour in
        Text("\(hour)")
          .rotationEffect(Current.clock.randomAngle() ?? .zero, anchor: .center)
          .scaleEffect(Current.clock.randomScale() ?? 1, anchor: .center)
          .position(.pointInCircle(
            from: Angle(degrees: Double(hour) * .hourInDegree),
            frame: geometry.localFrame,
            margin: geometry.localWidth * self.marginRatio
          ))
      }
    }
  }

  private var marginRatio: CGFloat {
    self.isHourIndicatorsShown || self.isMinuteIndicatorsShown
      ? Self.marginRatio
      : Self.marginRatio/2
  }

  private var configurationHours: [Int] {
    self.isLimitedHoursShown ? Self.limitedHours : Self.hours
  }
}

#if DEBUG
struct DrawnIndicators_Previews: PreviewProvider {
  static var previews: some View {
    DrawnIndicators(
      isHourIndicatorsShown: true,
      isMinuteIndicatorsShown: true,
      isLimitedHoursShown: false
    )
  }
}
#endif
