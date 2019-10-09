import SwiftUI

struct Clock: View {
  @Binding var date: Date
  let showClockFace: Bool

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .stroke(lineWidth: 4)
        Indicators()
        WatchPointers(date: self.$date)
        Circle()
          .fill()
          .frame(width: 20.0, height: 20.0, alignment: .center)
        ClockFace(animate: self.showClockFace)
          .opacity(self.showClockFace ? 1 : 0)
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
    Clock(date: .constant(Date()), showClockFace: true)
  }
}
#endif
