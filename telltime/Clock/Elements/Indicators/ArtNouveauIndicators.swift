import SwiftUI

struct ArtNouveauIndicators: View {
  private static let hourInDegree: Double = 30
  private static let marginRatio: CGFloat = 1/12
  private static let romanNumbers = ["XII", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI"]
  private static let limitedRomanNumbers = ["XII", "III", "VI", "IX"]
  @EnvironmentObject var configuration: ConfigurationStore

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ForEach(self.configurationRomanNumbers, id: \.self) { romanNumber in
          Text("\(romanNumber)")
            .modifier(NumberCircle(width: geometry.localWidth * 3/2 * Self.marginRatio))
            .position(.pointInCircle(
              from: self.angle(for: romanNumber),
              frame: geometry.localFrame,
              margin: geometry.localWidth * Self.marginRatio
            ))
        }
      }
      if self.configuration.showMinuteIndicators {
        Sun()
          .stroke()
      }
    }
  }

  private var configurationRomanNumbers: [String] {
    self.configuration.showLimitedHourIndicators ? Self.limitedRomanNumbers : Self.romanNumbers
  }

  private struct NumberCircle: ViewModifier {
    let width: CGFloat

    func body(content: Content) -> some View {
      content
        .background(
          Circle()
            .fill(Color.background)
            .frame(width: self.width, height: self.width)
        )
        .overlay(
          Circle()
            .stroke()
            .frame(width: self.width, height: self.width)
        )
    }
  }

  private func angle(for romanNumber: String) -> Angle {
    guard let index = Self.romanNumbers.firstIndex(of: romanNumber) else { return .zero }
    return Angle(degrees: Double(index) * Self.hourInDegree)
  }
}

struct Sun: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    path.move(to: .pointInCircle(
      from: .zero,
      frame: rect,
      margin: rect.width/6
    ))

    for minute in 1..<61 {
      let point: CGPoint = .pointInCircle(
        from: Angle(degrees: Double(minute) * 6),
        frame: rect,
        margin: rect.width/6
      )

      let control: CGPoint = .pointInCircle(
        from: Angle(degrees: Double(minute) * 6 - 3),
        frame: rect,
        margin: rect.width/4
      )

      path.addQuadCurve(to: point, control: control)
    }

    return path
  }
}

#if DEBUG
struct ArtNouveauIndicators_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      ArtNouveauIndicators()
      Circle()
        .stroke()
    }
  }
}
#endif
