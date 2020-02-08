import SwiftUI

struct ClockView: View {
    @EnvironmentObject var store: Store<App.State, App.Action>
    static let borderWidthRatio: CGFloat = 1/70

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ClockBorderView(clockStyle: self.store.state.configuration.clockStyle)
                IndicatorsContainer()
                Arms()
                ClockFaceView()
            }
            .frame(width: geometry.localDiameter, height: geometry.localDiameter)
            .fixedSize()
            .onTapGesture(count: 3, perform: self.showClockFace)
        }
    }

    private func showClockFace() {
        self.store.send(.clock(.showClockFace))
        self.store.send(Clock.delayClockFaceHidding())
    }
}

private struct ClockBorderView: View {
    let clockStyle: ClockStyle

    var body: some View {
        Group {
            if self.clockStyle == .artNouveau {
                ArtNouveauClockBorder()
            } else if self.clockStyle == .drawing {
                DrawnClockBorder()
            } else {
                ClassicClockBorder()
            }
        }
    }
}

#if DEBUG
struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView().padding()
            .environmentObject(App.previewStore)
    }
}

struct ClockViewWithFace_Previews: PreviewProvider {
    static var previewStoreWithShowFace: Store<App.State, App.Action> {
        var state = App.State()
        state.clock.isClockFaceShown = true
        return .init(initialState: state) { _, _ in }
    }

    static var previews: some View {
        ClockView().padding()
            .environmentObject(Self.previewStoreWithShowFace)
    }
}
#endif
