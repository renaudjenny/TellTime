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
  @GestureState private var dragAngle: Angle = .zero

    var body: some View {
        GeometryReader { geometry in
            self.arm
                .gesture(
                    DragGesture(coordinateSpace: .global).updating(self.$dragAngle) { value, state, _ in
                        state = self.angle(dragGestureValue: value, frame: geometry.frame(in: .global))
                    }
                    .onEnded({
                        self.angle = self.angle(dragGestureValue: $0, frame: geometry.frame(in: .global))
                    })
            )
                .rotationEffect(self.rotationAngle)
                .animation(self.bumpFreeSpring)
        }
    }

    private var arm: some View {
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
    }

    private var rotationAngle: Angle {
        dragAngle == .zero ? angle : dragAngle
    }

    private var bumpFreeSpring: Animation? {
        return dragAngle == .zero ? .spring() : nil
    }
}

// MARK: - Drag Gesture
extension Arm {
    private func angle(dragGestureValue: DragGesture.Value, frame: CGRect) -> Angle {
        let radius = min(frame.size.width, frame.size.height)/2
        let location = (
            x: dragGestureValue.location.x - radius - frame.origin.x,
            y: -(dragGestureValue.location.y - radius - frame.origin.y)
        )
        let arctan = atan2(location.x, location.y)
        return Angle(radians: Double(arctan).positiveRadians)
    }
}

enum ArmType {
  case hour
  case minute
}

#if DEBUG
struct Arm_Previews: PreviewProvider {
  static var previews: some View {
    Arm(
      clockStyle: .classic,
      lineWidthRatio: 1/2,
      marginRatio: 1/4,
      angle: .constant(.zero)
    )
  }
}

struct BiggerArm_Previews: PreviewProvider {
  static var previews: some View {
    Arm(
      clockStyle: .classic,
      lineWidthRatio: 2/3,
      marginRatio: 1/6,
      angle: .constant(.zero)
    )
      .previewDisplayName("Arm with 2/3 line with ratio and 1/6 margin ration with 0deg angle")
  }
}

struct ArmWithAnAngle_Previews: PreviewProvider {
  static var previews: some View {
      Arm(
        clockStyle: .classic,
        lineWidthRatio: 2/3,
        marginRatio: 1/6,
        angle: .constant(.degrees(20))
      )
  }
}

struct ArtNouveauDesignArm_Previews: PreviewProvider {
  static var previews: some View {
      Arm(
        clockStyle: .artNouveau,
        lineWidthRatio: 1/2,
        marginRatio: 1/4,
        angle: .constant(.zero)
      )
  }
}

struct DrawingDesignArm_Previews: PreviewProvider {
  static var previews: some View {
      Arm(
        clockStyle: .drawing,
        lineWidthRatio: 1/2,
        marginRatio: 1/4,
        angle: .constant(.zero)
      )
  }
}
#endif
