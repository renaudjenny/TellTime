import SwiftUI

struct WatchPointers: View {
  @ObservedObject var viewModel: WatchPointersViewModel

  var body: some View {
    ZStack {
      WatchPointer(
        lineWidthRatio: 1,
        marginRatio: 1/3,
        viewModel: self.viewModel.hourWatchPointerViewModel
      )
      WatchPointer(
        lineWidthRatio: 2/3,
        marginRatio: 1/10,
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
