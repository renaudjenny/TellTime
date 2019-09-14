import SwiftUI

struct Clock: View {
  @EnvironmentObject var store: Store

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .stroke(Color.black, lineWidth: 4)
        Indicators()
        WatchPointer(lineWidth: 6.0, margin: 40.0)
          .rotationEffect(self.hourIntoAngle(hour: self.store.hour, minute: self.store.minute))
          .animation(.easeOut)
        WatchPointer(lineWidth: 4.0, margin: 20.0)
          .rotationEffect(self.minuteIntoAngle(minute: self.store.minute))
          .animation(.easeOut)
        Circle()
          .fill()
          .frame(width: 20.0, height: 20.0, alignment: .center)
      }
        .frame(width: geometry.localDiameter, height: geometry.localDiameter)
        .fixedSize()
    }
  }

  private func hourIntoAngle(hour: Int, minute: Int) -> Angle {
    let hour: Double = Double(hour) + (minute > 0 ? Double(minute)/60 : 0)
    let relationship: Double = 360 / 12
    return Angle(degrees: Double(hour) * relationship)
  }

  private func minuteIntoAngle(minute: Int) -> Angle {
    let relationship: Double = 360 / 60
    return Angle(degrees: Double(minute) * relationship)
  }
}

struct WatchPointer: View {
  let lineWidth: CGFloat
  let margin: CGFloat

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        let center = geometry.localCenter
        let top = geometry.localTop
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x, y: top + self.margin))
      }.stroke(Color.black, lineWidth: self.lineWidth)
    }
  }
}

struct Indicators: View {
  private let margin: CGFloat = 16.0

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .center) {
        Text("12")
          .position(x: geometry.localCenter.x, y: geometry.localTop + self.margin)
        Text("3")
          .position(x: geometry.localWidth - self.margin, y: geometry.localCenter.y)
        Text("6")
          .position(x: geometry.localCenter.x, y: geometry.localBottom - self.margin)
        Text("9")
          .position(x: geometry.localLeft + self.margin, y: geometry.localCenter.y)
      }
    }
  }
}

fileprivate extension GeometryProxy {
  var localFrame: CGRect { self.frame(in: .local) }
  var localWidth: CGFloat { self.localFrame.width }
  var localHeight: CGFloat { self.localFrame.height }
  var localCenter: CGPoint { .init(x: self.localWidth/2, y: self.localHeight/2) }
  var localTop: CGFloat { self.localFrame.origin.y }
  var localBottom: CGFloat { self.localFrame.height }
  var localLeft: CGFloat { self.localFrame.origin.x }
  var localDiameter: CGFloat { return min(self.localWidth, self.localHeight) }
}

#if DEBUG
struct Clock_Previews : PreviewProvider {
    static var previews: some View {
        Clock()
    }
}
#endif
