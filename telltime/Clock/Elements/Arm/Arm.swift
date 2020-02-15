import SwiftUI

struct Arm: View {
    @EnvironmentObject var store: Store<App.State, App.Action>
    private var angle: Binding<Angle> {
        switch type {
        case .hour:
            return self.store.binding(for: \.clock.hourAngle) { .clock(.changeHourAngle($0)) }
        case .minute:
            return self.store.binding(for: \.clock.minuteAngle) { .clock(.changeMinuteAngle($0)) }
        }
    }
    @GestureState private var dragAngle: Angle = .zero
    private static let widthRatio: CGFloat = 1/50
    let type: ArmType

    var body: some View {
        GeometryReader { geometry in
            self.arm
                .gesture(
                    DragGesture(coordinateSpace: .global).updating(self.$dragAngle) { value, state, _ in
                        state = self.angle(dragGestureValue: value, frame: geometry.frame(in: .global))
                    }
                    .onEnded({
                        self.angle.wrappedValue = self.angle(dragGestureValue: $0, frame: geometry.frame(in: .global))
                    })
            )
        }
        .rotationEffect(self.rotationAngle)
        .animation(self.bumpFreeSpring)
        .onAppear(perform: self.setupAngle)
    }

    private var arm: some View {
        Group {
            if store.state.configuration.clockStyle == .artNouveau {
                ArtNouveauArm(type: self.type)
            } else if store.state.configuration.clockStyle == .drawing {
                DrawnArm(type: self.type)
            } else {
                ClassicArm(type: self.type)
            }
        }
    }

    private var rotationAngle: Angle {
        dragAngle == .zero ? angle.wrappedValue : dragAngle
    }

    private var bumpFreeSpring: Animation? {
        return dragAngle == .zero ? .spring() : nil
    }

    private func ratios(for type: ArmType) -> (lineWidthRatio: CGFloat, marginRatio: CGFloat) {
        switch type {
        case .hour: return (lineWidthRatio: 1/2, marginRatio: 2/5)
        case .minute: return (lineWidthRatio: 1/3, marginRatio: 1/8)
        }
    }

    private func setupAngle() {
        let date = self.store.state.clock.date
        switch self.type {
        case .hour: self.angle.wrappedValue = .fromHour(date: date)
        case .minute: self.angle.wrappedValue = .fromMinute(date: date)
        }
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

    typealias Ratio = (lineWidth: CGFloat, margin: CGFloat)
    private static let hourRatio: Ratio = (lineWidth: 1/2, margin: 2/5)
    private static let minuteRatio: Ratio = (lineWidth: 1/3, margin: 1/8)

    var ratio: Ratio {
        switch self {
        case .hour: return Self.hourRatio
        case .minute: return Self.minuteRatio
        }
    }
}

#if DEBUG
struct Arm_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Circle().stroke()
            Arm(type: .minute)
        }
        .padding()
        .environmentObject(App.previewStore)
    }
}

struct BiggerArm_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Circle().stroke()
            Arm(type: .hour)
        }
        .padding()
        .environmentObject(App.previewStore)
    }
}

struct ArmWithAnAngle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Circle().stroke()
            Arm(type: .minute)
        }
        .padding()
        .environmentObject(App.previewStore {
            $0.clock.minuteAngle = .degrees(20)
        })
    }
}

struct ArtNouveauDesignArm_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Circle().stroke()
            Arm(type: .minute)
        }
        .padding()
        .environmentObject(App.previewStore {
            $0.configuration.clockStyle = .artNouveau
        })
    }
}

struct DrawingDesignArm_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Circle().stroke()
            Arm(type: .minute)
        }
        .padding()
        .environmentObject(App.previewStore {
            $0.configuration.clockStyle = .drawing
        })
    }
}
#endif
