import SwiftUI

struct ClockFaceContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>

  var body: some View {
    ClockFace(isClockFaceShown: self.store.state.clock.isClockFaceShown)
  }
}

struct ClockFace: View {
  let isClockFaceShown: Bool

  var body: some View {
    GeometryReader { geometry in
      Eye(move: self.isClockFaceShown, position: .left)
        .frame(width: geometry.frame(in: .local).height/6, height: geometry.frame(in: .local).height/6)
        .position(
          x: geometry.frame(in: .local).width/3,
          y: geometry.frame(in: .local).width/3
        )
      Eye(move: self.isClockFaceShown, position: .right)
        .frame(width: geometry.frame(in: .local).height/6, height: geometry.frame(in: .local).height/6)
        .position(
          x: geometry.frame(in: .local).width/1.5,
          y: geometry.frame(in: .local).width/3
        )
      Mouth(shape: self.isClockFaceShown ? .smile : .neutral)
        .stroke(style: .init(lineWidth: 6.0, lineCap: .round, lineJoin: .round))
        .frame(width: geometry.frame(in: .local).width/3, height: geometry.frame(in: .local).height/6)
        .position(
          x: geometry.frame(in: .local).width/2,
          y: geometry.frame(in: .local).width/1.3
        )
    }
    .animation(.easeInOut)
  }
}

#if DEBUG
struct ClockFace_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ClockFace(isClockFaceShown: true)
        .padding()
        .frame(width: 300, height: 300)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Clock face shown")

      ClockFace(isClockFaceShown: false)
        .padding()
        .frame(width: 300, height: 300)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("Clock face hidden")
    }
  }
}
#endif
