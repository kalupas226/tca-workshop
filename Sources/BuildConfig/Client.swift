import Dependencies
import DependenciesMacros

@DependencyClient
public struct BuildConfig {
  public var gitHubPersonalAccessToken: () -> String = {
    // Use `unimplemented` for https://github.com/pointfreeco/swift-dependencies/issues/183.
    // If this bug is resolved, we will return the placeholder value directly.
    unimplemented(
      "\(Self.self).gitHubPersonalAccessToken",
      placeholder: ""
    )
  }
}
