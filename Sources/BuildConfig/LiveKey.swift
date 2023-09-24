import Dependencies
import Foundation

extension BuildConfig: DependencyKey {
  public static let liveValue = Self(
    gitHubPersonalAccessToken: {
      Bundle.main.infoDictionary?["GitHubPersonalAccessToken"] as? String ?? ""
    }
  )
}
