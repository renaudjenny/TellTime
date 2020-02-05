import SwiftUI

struct ClockFaceView: View {
    @EnvironmentObject var store: Store<App.State, App.Action>
    var isShown: Bool {
        self.store.state.clock.isClockFaceShown
    }

    var body: some View {
        GeometryReader { geometry in
            Eye(move: self.isShown, position: .left)
                .frame(width: geometry.frame(in: .local).height/6, height: geometry.frame(in: .local).height/6)
                .position(
                    x: geometry.frame(in: .local).width/3,
                    y: geometry.frame(in: .local).width/3
            )
            Eye(move: self.isShown, position: .right)
                .frame(width: geometry.frame(in: .local).height/6, height: geometry.frame(in: .local).height/6)
                .position(
                    x: geometry.frame(in: .local).width/1.5,
                    y: geometry.frame(in: .local).width/3
            )
            Mouth(shape: self.isShown ? .smile : .neutral)
                .stroke(style: .init(lineWidth: 6.0, lineCap: .round, lineJoin: .round))
                .frame(width: geometry.frame(in: .local).width/3, height: geometry.frame(in: .local).height/6)
                .position(
                    x: geometry.frame(in: .local).width/2,
                    y: geometry.frame(in: .local).width/1.3
            )
        }
        .opacity(isShown ? 1 : 0)
        .animation(.easeInOut)
    }
}

#if DEBUG
struct ClockFaceSmiling_Previews: PreviewProvider {
    static var previewStoreWithShowFace: Store<App.State, App.Action> {
        var state = App.State()
        state.clock.isClockFaceShown = true
        return .init(initialState: state) { _, _ in }
    }

    static var previews: some View {
        ClockFaceView()
            .environmentObject(Self.previewStoreWithShowFace)
    }
}
#endif
