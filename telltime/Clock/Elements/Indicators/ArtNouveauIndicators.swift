import SwiftUI

struct ArtNouveauIndicators: View {
    @EnvironmentObject var store: Store<App.State, App.Action>
    private static let hourInDegree: Double = 30
    private static let marginRatio: CGFloat = 1/12
    private static let romanNumbers = ["XII", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI"]
    private static let limitedRomanNumbers = ["XII", "III", "VI", "IX"]

    var body: some View {
        ZStack {
            ForEach(configurationRomanNumbers, id: \.self) { romanNumber in
                self.romanHour(for: romanNumber)
            }
            if store.state.configuration.isMinuteIndicatorsShown {
                Sun()
                    .stroke()
                    .modifier(ScaleUpOnAppear())
            }
        }
    }

    func romanHour(for romanNumber: String) -> some View {
        GeometryReader { geometry in
            Text(romanNumber)
                .modifier(NumberCircle(width: geometry.localDiameter * 3/2 * Self.marginRatio))
                .modifier(ScaleUpOnAppear())
                .position(.pointInCircle(
                    from: self.angle(for: romanNumber),
                    frame: geometry.localFrame,
                    margin: geometry.localDiameter * Self.marginRatio
                    ))
        }
    }

    private var configurationRomanNumbers: [String] {
        self.store.state.configuration.isLimitedHoursShown ? Self.limitedRomanNumbers : Self.romanNumbers
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

    private struct Sun: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()

            path.move(to: .pointInCircle(
                from: .zero,
                frame: rect,
                margin: rect.width/6
                ))

            for minute in 1...60 {
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
}

#if DEBUG
struct ArtNouveauIndicators_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Circle().stroke()
            ArtNouveauIndicators()
                .environmentObject(App.previewStore)
        }.padding()
    }
}
#endif
