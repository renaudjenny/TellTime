import SwiftUI

struct ClockFace: View {
  @EnvironmentObject var store: Store

  var body: some View {
    GeometryReader { geometry in
      Eye(position: .left)
        .frame(width: geometry.frame(in: .local).height/6, height: geometry.frame(in: .local).height/6)
        .position(
          x: geometry.frame(in: .local).width/3,
          y: geometry.frame(in: .local).width/3
        )
      Eye(position: .right)
        .frame(width: geometry.frame(in: .local).height/6, height: geometry.frame(in: .local).height/6)
        .position(
          x: geometry.frame(in: .local).width/1.5,
          y: geometry.frame(in: .local).width/3
        )
      Mouth(shape: self.store.showClockFace ? .smile : .neutral)
        .stroke(style: .init(lineWidth: 6.0, lineCap: .round, lineJoin: .round))
        .position(
          x: geometry.frame(in: .local).width/2,
          y: geometry.frame(in: .local).width/1.3
        )
        .frame(width: geometry.frame(in: .local).width/3, height: geometry.frame(in: .local).height/6)
    }
    .opacity(self.store.showClockFace ? .opac : .transparent)
    .animation(.easeInOut)
  }
}

fileprivate extension Double {
  static let transparent = 0.0
  static let opac = 1.0
}

struct ClockFace_Previews: PreviewProvider {
  static var previews: some View {
    ClockFace()
  }
}
