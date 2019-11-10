import SwiftUI

struct ScaleUpOnAppear: ViewModifier {
  @State var isShown = false

  func body(content: Content) -> some View {
    content
      .scaleEffect(self.isShown ? 1 : 0.1)
      .animation(.spring())
      .onAppear(perform: { self.isShown = true })
  }
}
