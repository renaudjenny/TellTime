import SwiftUI

struct Indicators: View {
  private static let hourInDegree: Double = 30
  private static let limitedHourInDegree: Double = 90
  private static let hourDotRatio: CGFloat = 1/35
  private static let minuteInDegree: Double = 6
  private static let minuteDotRatio: CGFloat = 1/70
  private static let marginRatio: CGFloat = 1/7
  @ObservedObject var viewModel = IndicatorsViewModel()
  @EnvironmentObject var configuration: ConfigurationStore

  func textMargin(width: CGFloat) -> CGFloat {
    let showDotIndicators = self.configuration.showMinuteIndicators || self.configuration.showHourIndicators
    return showDotIndicators ? width * Self.marginRatio : width * Self.marginRatio/2
  }

  var body: some View {
    ZStack(alignment: .center) {
      if self.configuration.showLimitedHourIndicators {
        self.limitedHourTexts
      } else {
        self.hourTexts
      }
      if self.configuration.showHourIndicators {
        self.hourIndicators
      }
      if self.configuration.showMinuteIndicators {
        self.minuteIndicators
      }
    }
    .animation(.easeInOut)
  }

  var hourTexts: some View {
    GeometryReader { geometry in
      ForEach(1..<13) { hour in
        Text("\(hour)")
          .position(self.viewModel.positionInCircle(
            from: Angle(degrees: Double(hour) * Self.hourInDegree),
            frame: geometry.localFrame,
            margin: self.textMargin(width: geometry.localWidth)
          ))
      }
    }
  }

  var limitedHourTexts: some View {
    GeometryReader { geometry in
      ForEach(1..<13) { hour in
        Text(self.limitedHourText(hour: hour))
          .position(self.viewModel.positionInCircle(
            from: Angle(degrees: Double(hour/3) * Self.limitedHourInDegree),
            frame: geometry.localFrame,
            margin: self.textMargin(width: geometry.localWidth)
          ))
      }
    }
  }

  private func limitedHourText(hour: Int) -> String {
    hour % 3 == 0 ? "\(hour)" : ""
  }

  var hourIndicators: some View {
    GeometryReader { geometry in
      ForEach(1..<13) { hour in
        Circle()
          .frame(width: geometry.localWidth * Self.hourDotRatio)
          .position(self.viewModel.positionInCircle(
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
          .position(self.viewModel.positionInCircle(
            from: Angle(degrees: Double(minute) * Self.minuteInDegree),
            frame: geometry.localFrame,
            margin: geometry.localWidth * Self.marginRatio/3
          ))
      }
    }
  }
}

#if DEBUG
struct Indicators_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Indicators()
      Circle()
        .stroke()
    }
  }
}
#endif
