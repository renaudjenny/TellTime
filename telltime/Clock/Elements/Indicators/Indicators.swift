import SwiftUI

struct IndicatorsContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>

  var body: some View {
    Indicators(clockStyle: self.store.state.configuration.clockStyle)
  }
}

struct Indicators: View {
  let clockStyle: ClockStyle

  var body: some View {
    Group {
      if self.clockStyle == .artNouveau {
        ArtNouveauIndicatorsContainer()
      } else if self.clockStyle == .drawing {
        DrawnIndicatorsContainer()
      } else {
        ClassicIndicatorsContainer()
      }
    }
  }
}

#if DEBUG
struct Indicators_Previews: PreviewProvider {
  private static func indicators(style: ClockStyle) -> some View {
    ZStack {
      Indicators(clockStyle: style)
        .environmentObject(App.previewStore)
    }
  }

  static var previews: some View {
    Group {
      Self.indicators(style: .classic)
        .previewDevice("iPhone SE")
        .previewDisplayName("Indicators Classic")
      Self.indicators(style: .artNouveau)
        .previewDevice("iPhone SE")
        .previewDisplayName("Indicators Art Nouveau")
      Self.indicators(style: .drawing)
        .previewDevice("iPhone SE")
        .previewDisplayName("Indicators Art Nouveau")
    }
  }
}
#endif
