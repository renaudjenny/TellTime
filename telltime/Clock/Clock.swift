import SwiftUI

struct Clock: View {
  @ObservedObject var viewModel: ClockViewModel

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .stroke(lineWidth: 4)
        Indicators()
        WatchPointers(
          viewModel: WatchPointersViewModel(date: self.viewModel.date)
        )
        ClockFace(animate: self.viewModel.showClockFace)
          .opacity(self.viewModel.showClockFace ? 1 : 0)
      }
      .frame(width: geometry.localDiameter, height: geometry.localDiameter)
      .fixedSize()
    }
    .frame(maxWidth: 500, maxHeight: 500)
  }
}

#if DEBUG
struct Clock_Previews: PreviewProvider {
  static var previews: some View {
    let viewModel = ClockViewModel(date: .constant(Date()), showClockFace: true)
    return Clock(viewModel: viewModel)
  }
}
#endif
