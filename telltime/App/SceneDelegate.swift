import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let store = Store<App.State, App.Action>(initialState: App.State(), reducer: App.reducer)
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = UIHostingController(
      rootView: RootView()
        .environmentObject(store)
    )
    self.window = window
    window.makeKeyAndVisible()

    self.customizeAppearance()
  }

  private func customizeAppearance() {
    UINavigationBar.appearance().tintColor = UIColor.red
  }
}
