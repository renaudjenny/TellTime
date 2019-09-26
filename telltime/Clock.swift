import SwiftUI

struct Clock: View {
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .stroke(lineWidth: 4)
        Indicators()
        WatchPointers()
        Circle()
          .fill()
          .frame(width: 20.0, height: 20.0, alignment: .center)
      }
      .frame(width: geometry.localDiameter, height: geometry.localDiameter)
      .fixedSize()
    }
    .frame(maxWidth: 500, maxHeight: 500)
  }
}

struct WatchPointers: View {
  @EnvironmentObject var store: Store

  var body: some View {
    ZStack {
      WatchPointer(
        lineWidth: 6.0,
        margin: 40.0,
        rotationAngle: RotationAngle(angle: self.hourIntoAngle(date: self.store.date))
      )
      WatchPointer(
        lineWidth: 4.0,
        margin: 20.0,
        rotationAngle: RotationAngle(angle: self.minuteIntoAngle(date: self.store.date))
      )
    }
  }

  private func hourIntoAngle(date: Date) -> Angle {
    let minutes = Double(Calendar.current.component(.minute, from: date))
    let minutesInHour = minutes > 0 ? minutes/60 : 0
    let hour = Double(Calendar.current.component(.hour, from: date)) + minutesInHour

    let relationship: Double = 360 / 12
    return Angle(degrees: hour * relationship)
  }

  private func minuteIntoAngle(date: Date) -> Angle {
    let minutes = Double(Calendar.current.component(.minute, from: date))
    let relationship: Double = 360 / 60
    return Angle(degrees: Double(minutes) * relationship)
  }
}

struct WatchPointer: View {
  let lineWidth: CGFloat
  let margin: CGFloat
  @ObservedObject var rotationAngle: RotationAngle

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        let center = geometry.localCenter
        let top = geometry.localTop
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x, y: top + self.margin))
      }
      .stroke(lineWidth: self.lineWidth)
      .gesture(DragGesture(coordinateSpace: .global)
        .onChanged({ self.changePointerGesture($0, frame: geometry.frame(in: .global)) })
      )
      .rotationEffect(self.rotationAngle.angle)
      .animation(.easeOut)
    }
  }

  private func changePointerGesture(_ value: DragGesture.Value, frame: CGRect) {
    let radius = frame.size.width/2
    let location = (
      x: value.location.x - radius - frame.origin.x,
      y: -(value.location.y - radius - frame.origin.y)
    )
    let arctan = atan2(location.x, location.y)
    self.rotationAngle.angle = Angle(radians: Double(arctan))
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

final class RotationAngle: ObservableObject {
  @Published var angle: Angle

  init(angle: Angle) {
    self.angle = angle
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
