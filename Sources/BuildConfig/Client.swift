import Dependencies
import DependenciesMacros

@DependencyClient
public struct BuildConfig {
  public var gitHubPersonalAccessToken: () -> String = { "" }
}

