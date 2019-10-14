import SwiftUI

struct Indicators: View {
  private static let hourInDegree: Double = 30
  private static let limitedHourInDegree: Double = 90
  private static let hourDotSize: CGFloat = 10
  private static let minuteInDegree: Double = 6
  private static let minuteDotSize: CGFloat = 5
  private static let margin: CGFloat = 40.0
  @ObservedObject var viewModel = IndicatorsViewModel()
  @EnvironmentObject var configuration: ConfigurationStore

  var textMargin: CGFloat {
    self.configuration.showMinuteIndicators || self.configuration.showHourIndicators ? Self.margin : Self.margin/3
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
            margin: self.textMargin
          ))
      }
    }
  }

  var limitedHourTexts: some View {
    GeometryReader { geometry in
      ForEach(1..<5) { hour in
        Text("\(hour * 3)")
          .position(self.viewModel.positionInCircle(
            from: Angle(degrees: Double(hour) * Self.limitedHourInDegree),
            frame: geometry.localFrame,
            margin: self.textMargin
          ))
      }
    }
  }

  var hourIndicators: some View {
    GeometryReader { geometry in
      ForEach(1..<13) { hour in
        Circle()
          .frame(width: Self.hourDotSize)
          .position(self.viewModel.positionInCircle(
            from: Angle(degrees: Double(hour) * Self.hourInDegree),
            frame: geometry.localFrame,
            margin: Self.margin/3
          ))
      }
    }
  }

  var minuteIndicators: some View {
    GeometryReader { geometry in
      ForEach(1..<61) { minute in
        Circle()
          .frame(width: Self.minuteDotSize)
          .position(self.viewModel.positionInCircle(
            from: Angle(degrees: Double(minute) * Self.minuteInDegree),
            frame: geometry.localFrame,
            margin: Self.margin/3
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
