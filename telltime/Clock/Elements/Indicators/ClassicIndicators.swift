import SwiftUI

struct ClassicIndicators: View {
  private static let hourInDegree: Double = 30
  private static let hourDotRatio: CGFloat = 1/35
  private static let minuteInDegree: Double = 6
  private static let minuteDotRatio: CGFloat = 1/70
  private static let marginRatio: CGFloat = 1/7
  private static let hours = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  private static let limitedHours = [12, 3, 6, 9]
  @EnvironmentObject var configuration: ConfigurationStore

  func textMargin(width: CGFloat) -> CGFloat {
    let showDotIndicators = self.configuration.showMinuteIndicators || self.configuration.showHourIndicators
    return showDotIndicators ? width * Self.marginRatio : width * Self.marginRatio/2
  }

  var body: some View {
    ZStack(alignment: .center) {
      self.texts
      if self.configuration.showHourIndicators {
        self.hourIndicators
      }
      if self.configuration.showMinuteIndicators {
        self.minuteIndicators
      }
    }
  }

  var texts: some View {
    GeometryReader { geometry in
      ForEach(self.configurationHours, id: \.self) { hour in
        Text("\(hour)")
          .position(.pointInCircle(
            from: Angle(degrees: Double(hour) * Self.hourInDegree),
            frame: geometry.localFrame,
            margin: self.textMargin(width: geometry.localWidth)
          ))
      }
    }
  }

  private var configurationHours: [Int] {
    self.configuration.showLimitedHourIndicators ? Self.limitedHours : Self.hours
  }

  var hourIndicators: some View {
    GeometryReader { geometry in
      ForEach(1..<13) { hour in
        Circle()
          .frame(width: geometry.localWidth * Self.hourDotRatio)
          .position(.pointInCircle(
            from: Angle(degrees: Double(hour) * Self.hourInDegree),
            frame: geometry.localFrame,
            margin: geometry.localWidth * Self.marginRatio/3
          ))
      }
    }
  }

  var minuteIndicators: some View {
    GeometryReader { geometry in
      ForEach(1..<61) { minute in
        Circle()
          .frame(width: geometry.localWidth * Self.minuteDotRatio)
          .position(.pointInCircle(
            from: Angle(degrees: Double(minute) * Self.minuteInDegree),
            frame: geometry.localFrame,
            margin: geometry.localWidth * Self.marginRatio/3
          ))
      }
    }
  }
}

#if DEBUG
struct ClassicIndicators_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      ClassicIndicators()
      Circle()
        .stroke()
    }
  }
}
#endif
