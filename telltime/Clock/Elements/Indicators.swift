import SwiftUI

struct Indicators: View {
  private static let hourInDegree: Double = 30
  private static let hourDotSize: CGFloat = 10
  private static let minuteInDegree: Double = 6
  private static let minuteDotSize: CGFloat = 5
  private static let margin: CGFloat = 40.0
  @ObservedObject var viewModel = IndicatorsViewModel()

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .center) {
        ForEach(1..<13) { hour in
          ZStack {
            Text("\(hour)")
              .position(self.viewModel.positionInCircle(
                from: Angle(degrees: Double(hour) * Self.hourInDegree),
                frame: geometry.localFrame,
                margin: Self.margin
              ))
            Circle()
              .frame(width: Self.hourDotSize)
              .position(self.viewModel.positionInCircle(
                from: Angle(degrees: Double(hour) * Self.hourInDegree),
                frame: geometry.localFrame,
                margin: Self.margin/3
              ))
          }
        }
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
