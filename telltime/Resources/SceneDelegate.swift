import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(
        rootView: TellTime()
          .environmentObject(ConfigurationStore())
          .environmentObject(ClockStore())
          .environmentObject(TTS())
      )
      self.window = window
      window.makeKeyAndVisible()
    }
    self.customizeAppearance()
  }

  private func customizeAppearance() {
    UINavigationBar.appearance().tintColor = UIColor.red
  }
}
