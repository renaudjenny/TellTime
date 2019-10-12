import SwiftUI

struct WatchPointers: View {
  @ObservedObject var viewModel: WatchPointersViewModel

  var body: some View {
    ZStack {
      WatchPointer(
        lineWidth: 6.0,
        margin: 40.0,
        viewModel: self.viewModel.hourWatchPointerViewModel
      )
      WatchPointer(
        lineWidth: 4.0,
        margin: 20.0,
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
