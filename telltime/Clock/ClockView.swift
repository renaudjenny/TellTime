import SwiftUI

struct ClockView: View {
    @EnvironmentObject var store: Store<App.State, App.Action>
    static let borderWidthRatio: CGFloat = 1/70

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ClockBorderView()
                IndicatorsView()
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
    @EnvironmentObject var store: Store<App.State, App.Action>

    var body: some View {
        Group {
            if store.state.configuration.clockStyle == .artNouveau {
                ArtNouveauClockBorder()
            } else if store.state.configuration.clockStyle == .drawing {
                DrawnClockBorder()
            } else {
                ClassicClockBorder()
            }
        }
    }
}

private struct IndicatorsView: View {
    @EnvironmentObject var store: Store<App.State, App.Action>

    var body: some View {
        Group {
            if store.state.configuration.clockStyle == .artNouveau {
                ArtNouveauIndicatorsContainer()
            } else if store.state.configuration.clockStyle == .drawing {
                DrawnIndicatorsContainer()
            } else {
                ClassicIndicatorsContainer()
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
    static var previews: some View {
        ClockView().padding()
            .environmentObject(App.previewStore {
                $0.clock.isClockFaceShown = true
            })
    }
}

struct ClockViewArtNouveauStyle_Previews: PreviewProvider {
    static var previews: some View {
        ClockView().padding()
            .environmentObject(App.previewStore {
                $0.configuration.clockStyle = .artNouveau
            })
    }
}

struct ClockViewDrawingStyle_Previews: PreviewProvider {
    static var previews: some View {
        ClockView().padding()
            .environmentObject(App.previewStore {
                $0.configuration.clockStyle = .drawing
            })
    }
}
#endif
