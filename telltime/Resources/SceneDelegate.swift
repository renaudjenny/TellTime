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
      let configurationStore = ConfigurationStore()
      window.rootViewController = UIHostingController(
        rootView: TellTime(viewModel: TellTimeViewModel(
          configuration: configurationStore
        ))
          .environmentObject(configurationStore)
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
