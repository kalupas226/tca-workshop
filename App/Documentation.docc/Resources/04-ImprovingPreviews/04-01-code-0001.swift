import Entity

public struct GitHubAPIClient {
  public var searchRepositories: @Sendable (_ query: String) async throws -> [Repository]
}
