import SwiftUI

struct ClockFace: View {
  @EnvironmentObject var store: Store

  var body: some View {
    GeometryReader { geometry in
      Circle()
        .fill()
        .frame(width: 15.0, height: 15.0)
        .position(
          x: geometry.frame(in: .local).width/3,
          y: geometry.frame(in: .local).width/3
        )
      Circle()
        .fill()
        .frame(width: 15.0, height: 15.0)
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
        .frame(width: 150.0, height: 40.0)
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
