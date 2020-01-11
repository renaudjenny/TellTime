import SwiftUI

struct ClockBorderContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  let localWidth: CGFloat

  var body: some View {
    ClockBorder(
      localWidth: self.localWidth,
      clockStyle: self.store.state.configuration.clockStyle
    )
  }
}

struct ClockBorder: View {
  let localWidth: CGFloat
  let clockStyle: ClockStyle

  var body: some View {
    Group {
      if self.clockStyle == .artNouveau {
        ArtNouveauClockBorder(localWidth: self.localWidth)
      } else if self.clockStyle == .drawing {
        DrawnClockBorder(localWidth: self.localWidth)
      } else {
        ClassicClockBorder(localWidth: self.localWidth)
      }
    }
  }
}

#if DEBUG
struct ClockBorder_Previews: PreviewProvider {
  private static func clockBorder(style: ClockStyle) -> some View {
    ClockBorder(localWidth: 300, clockStyle: style)
  }

  static var previews: some View {
    Group {
      Self.clockBorder(style: .classic)
        .previewDevice("iPhone SE")
        .previewDisplayName("Indicators Classic")
      Self.clockBorder(style: .artNouveau)
        .previewDevice("iPhone SE")
        .previewDisplayName("Indicators Art Nouveau")
      Self.clockBorder(style: .drawing)
        .previewDevice("iPhone SE")
        .previewDisplayName("Indicators Drawing")
    }
  }
}
#endif
