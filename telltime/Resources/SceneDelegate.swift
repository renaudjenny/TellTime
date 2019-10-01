import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  var store: Store?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      let store = Store()
      self.store = store
      window.rootViewController = UIHostingController(rootView: TellTime().environmentObject(store))
      self.window = window
      window.makeKeyAndVisible()
    }
  }
}
