import SwiftUI

struct Indicators: View {
  @EnvironmentObject var configuration: ConfigurationStore

  var body: some View {
    Group {
      if self.configuration.clockStyle == .artNouveau {
        ArtNouveauIndicators()
      } else {
        ClassicIndicators()
      }
    }
    .animation(.easeInOut)
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
