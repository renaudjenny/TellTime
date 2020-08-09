import UIKit
import SwiftUI
import SwiftTTSCombine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        let store = appStore()

        window.rootViewController = UIHostingController(
            rootView: TellTimeView().environmentObject(store)
        )
        self.window = window
        window.makeKeyAndVisible()

        self.customizeAppearance()
    }

    private func customizeAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.red
    }

    private func appStore() -> Store<App.State, App.Action, App.Environment> {
        let initialEnvironment = EnvironmentValues()
        let environment = App.Environment(
            currentDate: { Date() },
            tts: TTS.Environment(
                engine: Engine(),
                calendar: initialEnvironment.calendar,
                tellTime: initialEnvironment.tellTime
            )
        )
        return .init(
            initialState: App.State(date: Date()),
            reducer: App.reducer,
            environment: environment
        )
    }
}
