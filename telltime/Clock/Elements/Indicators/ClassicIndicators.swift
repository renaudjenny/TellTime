import SwiftUI

struct ClassicIndicatorsContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>

  var body: some View {
    ClassicIndicators(
      isHourIndicatorsShown: self.store.state.configuration.isHourIndicatorsShown,
      isMinuteIndicatorsShown: self.store.state.configuration.isMinuteIndicatorsShown,
      isLimitedHoursShown: self.store.state.configuration.isLimitedHoursShown
    )
  }
}

struct ClassicIndicators: View {
  let isHourIndicatorsShown: Bool
  let isMinuteIndicatorsShown: Bool
  let isLimitedHoursShown: Bool
  private static let marginRatio: CGFloat = 1/7

  var body: some View {
    ZStack(alignment: .center) {
      HourTexts(
        marginRatio: Self.marginRatio,
        isLimitedHoursShown: self.isLimitedHoursShown,
        isMinuteIndicatorsShown: self.isMinuteIndicatorsShown,
        isHourIndicatorsShown: self.isHourIndicatorsShown
      )
      if self.isHourIndicatorsShown {
        HourIndicators(marginRatio: Self.marginRatio)
      }
      if self.isMinuteIndicatorsShown {
        MinuteIndicators(marginRatio: Self.marginRatio)
      }
    }
    .modifier(ScaleUpOnAppear())
  }
}

private struct HourTexts: View {
  private static let hours = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  private static let limitedHours = [12, 3, 6, 9]
  let marginRatio: CGFloat
  let isLimitedHoursShown: Bool
  let isMinuteIndicatorsShown: Bool
  let isHourIndicatorsShown: Bool

  var body: some View {
    GeometryReader { geometry in
      ForEach(self.configurationHours, id: \.self) { hour in
        Text("\(hour)")
          .position(.pointInCircle(
            from: Angle(degrees: Double(hour) * .hourInDegree),
            frame: geometry.localFrame,
            margin: geometry.localDiameter * self.dynamicMarginRatio
          ))
      }
    }
  }

  private var configurationHours: [Int] {
    self.isLimitedHoursShown ? Self.limitedHours : Self.hours
  }

  private var dynamicMarginRatio: CGFloat {
    self.isMinuteIndicatorsShown || self.isHourIndicatorsShown
      ? self.marginRatio
      : self.marginRatio/2
  }
}

private struct HourIndicators: View {
  private static let hourDotRatio: CGFloat = 1/35
  let marginRatio: CGFloat

  var body: some View {
    GeometryReader { geometry in
      ForEach(1..<13) { hour in
        Circle()
          .frame(width: geometry.localDiameter * Self.hourDotRatio)
          .position(.pointInCircle(
            from: Angle(degrees: Double(hour) * .hourInDegree),
            frame: geometry.localFrame,
            margin: geometry.localDiameter * self.marginRatio/3
          ))
      }
    }
  }
}

private struct MinuteIndicators: View {
  private static let minuteDotRatio: CGFloat = 1/70
  let marginRatio: CGFloat

  var body: some View {
    GeometryReader { geometry in
      ForEach(1..<61) { minute in
        Circle()
          .frame(width: geometry.localDiameter * Self.minuteDotRatio)
          .position(.pointInCircle(
            from: Angle(degrees: Double(minute) * .minuteInDegree),
            frame: geometry.localFrame,
            margin: geometry.localDiameter * self.marginRatio/3
          ))
      }
    }
  }
}

#if DEBUG
struct ClassicIndicators_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      ClassicIndicators(
        isHourIndicatorsShown: true,
        isMinuteIndicatorsShown: true,
        isLimitedHoursShown: false
      )
      Circle()
        .stroke()
    }
  }
}
#endif
