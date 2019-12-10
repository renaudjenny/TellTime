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
  static var previews: some View {
    ZStack {
      Indicators(clockStyle: .artNouveau)
        .environmentObject(App.previewStore)
      Circle()
        .stroke()
    }
  }
}
#endif
