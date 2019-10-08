import SwiftUI

struct ClockFace: View {
  let animate: Bool

  var body: some View {
    GeometryReader { geometry in
      Eye(move: self.animate, position: .left)
        .frame(width: geometry.frame(in: .local).height/6, height: geometry.frame(in: .local).height/6)
        .position(
          x: geometry.frame(in: .local).width/3,
          y: geometry.frame(in: .local).width/3
        )
      Eye(move: self.animate, position: .right)
        .frame(width: geometry.frame(in: .local).height/6, height: geometry.frame(in: .local).height/6)
        .position(
          x: geometry.frame(in: .local).width/1.5,
          y: geometry.frame(in: .local).width/3
        )
      Mouth(shape: self.animate ? .smile : .neutral)
        .stroke(style: .init(lineWidth: 6.0, lineCap: .round, lineJoin: .round))
        .position(
          x: geometry.frame(in: .local).width/2,
          y: geometry.frame(in: .local).width/1.3
        )
        .frame(width: geometry.frame(in: .local).width/3, height: geometry.frame(in: .local).height/6)
    }
    .animation(.easeInOut)
  }
}

struct ClockFace_Previews: PreviewProvider {
  static var previews: some View {
    return ClockFace(animate: true)
  }
}
