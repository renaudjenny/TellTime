import SwiftUI

struct WatchPointers: View {
  @ObservedObject var viewModel: WatchPointersViewModel

  var body: some View {
    ZStack {
      WatchPointer(
        lineWidthRatio: 1/2,
        marginRatio: 2/5,
        viewModel: self.viewModel.hourWatchPointerViewModel
      )
      WatchPointer(
        lineWidthRatio: 1/3,
        marginRatio: 1/8,
        viewModel: self.viewModel.minuteWatchPointerViewModel
      )
    }
  }
}

#if DEBUG
struct WatchPointers_Previews: PreviewProvider {
  static var previews: some View {
    WatchPointers(viewModel: WatchPointersViewModel(
      date: .constant(Date(timeIntervalSince1970: 123))
    ))
  }
}
#endif
