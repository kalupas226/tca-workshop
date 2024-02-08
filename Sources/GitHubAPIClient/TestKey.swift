import Dependencies
import XCTestDynamicOverlay

extension DependencyValues {
  public var gitHubAPIClient: GitHubAPIClient {
    get { self[GitHubAPIClient.self] }
    set { self[GitHubAPIClient.self] = newValue }
  }
}

extension GitHubAPIClient: TestDependencyKey {
  public static let previewValue = Self(
    searchRepositories: { _ in [] }
  )

  public static let testValue = Self()
}
