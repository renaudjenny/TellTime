import SwiftUI

struct ArmContainer: View {
  @EnvironmentObject var store: Store<App.State, App.Action>
  private var angle: Binding<Angle> {
    switch type {
    case .hour:
      return self.store.binding(for: \.clock.hourAngle) { .clock(.changeHourAngle($0)) }
    case .minute:
      return self.store.binding(for: \.clock.minuteAngle) { .clock(.changeMinuteAngle($0)) }
    }
  }
  let type: ArmType

  var body: some View {
    Arm(
      clockStyle: self.store.state.configuration.clockStyle,
      lineWidthRatio: self.ratios(for: self.type).lineWidthRatio,
      marginRatio: self.ratios(for: self.type).marginRatio,
      angle: self.angle
    )
      .onAppear(perform: self.setupAngle)
  }

  private func setupAngle() {
    let date = self.store.state.clock.date
    switch self.type {
    case .hour: self.angle.wrappedValue = .fromHour(date: date)
    case .minute: self.angle.wrappedValue = .fromMinute(date: date)
    }
  }

  private func ratios(for type: ArmType) -> (lineWidthRatio: CGFloat, marginRatio: CGFloat) {
    switch type {
    case .hour: return (lineWidthRatio: 1/2, marginRatio: 2/5)
    case .minute: return (lineWidthRatio: 1/3, marginRatio: 1/8)
    }
  }
}

struct Arm: View {
  private static let widthRatio: CGFloat = 1/50
  let clockStyle: ClockStyle
  let lineWidthRatio: CGFloat
  let marginRatio: CGFloat
  @Binding var angle: Angle
  @State private var draggingAngle: Angle = .zero
  @State private var animate = true

  var body: some View {
    GeometryReader { geometry in
      Group {
        if self.clockStyle == .artNouveau {
          ArtNouveauArm(
            lineWidthRatio: self.lineWidthRatio,
            marginRatio: self.marginRatio
          )
        } else if self.clockStyle == .drawing {
          DrawnArm(
            lineWidthRatio: self.lineWidthRatio,
            marginRatio: self.marginRatio
          )
        } else {
          ClassicArm(
            lineWidthRatio: self.lineWidthRatio,
            marginRatio: self.marginRatio
          )
        }
      }
      .gesture(self.dragGesture(globalFrame: geometry.frame(in: .global)))
      .rotationEffect(self.animate ? self.angle : self.draggingAngle)
      .animation(self.animate ? .spring() : nil)
    }
  }
}

// MARK: - Drag Gesture
extension Arm {
  func dragGesture(globalFrame: CGRect) -> AnyGesture<DragGesture.Value> {
    return AnyGesture<DragGesture.Value>(
      DragGesture(coordinateSpace: .global)
        .onChanged({ self.moveArmGesture($0, frame: globalFrame) })
        .onEnded({ self.updateArmAngleGesture($0, frame: globalFrame) })
    )
  }

  private func angle(dragGestureValue: DragGesture.Value, frame: CGRect) -> Angle {
    let radius = frame.size.width/2
    let location = (
      x: dragGestureValue.location.x - radius - frame.origin.x,
      y: -(dragGestureValue.location.y - radius - frame.origin.y)
    )
    let arctan = atan2(location.x, location.y)
    return Angle(radians: Double(arctan).positiveRadians)
  }

  private func moveArmGesture(_ value: DragGesture.Value, frame: CGRect) {
    self.animate = false
    self.draggingAngle = self.angle(dragGestureValue: value, frame: frame)
  }

  private func updateArmAngleGesture(_ value: DragGesture.Value, frame: CGRect) {
    self.angle = self.angle(dragGestureValue: value, frame: frame)
    self.animate = true
  }
}

enum ArmType {
  case hour
  case minute
}

#if DEBUG
struct Arm_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ZStack {
        Circle()
          .stroke()
        Arm(
          clockStyle: .classic,
          lineWidthRatio: 1/2,
          marginRatio: 1/4,
          angle: .constant(.zero)
        )
      }
      .frame(width: 300, height: 300)
      .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
      .previewDisplayName("Classic Arm")

      ZStack {
        Circle()
          .stroke()
        Arm(
          clockStyle: .artNouveau,
          lineWidthRatio: 1/2,
          marginRatio: 1/4,
          angle: .constant(.zero)
        )
      }
      .frame(width: 300, height: 300)
      .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
      .previewDisplayName("Art Nouveau Arm")

      ZStack {
        Circle()
          .stroke()
        Arm(
          clockStyle: .drawing,
          lineWidthRatio: 1/2,
          marginRatio: 1/4,
          angle: .constant(.zero)
        )
      }
      .frame(width: 300, height: 300)
      .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
      .previewDisplayName("Art Nouveau Arm")
    }
  }
}
#endif
