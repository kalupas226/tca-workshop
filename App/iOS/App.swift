import AppFeature
import SwiftUI

@main
struct TCAWorkshopApp: SwiftUI.App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: .init(
          initialState: App.State()
        ) {
          App()
        }
      )
    }
  }
}
