import ComposableArchitecture
import Entity
import Foundation

extension GitHubAPIClient: DependencyKey {
  public static let liveValue = Self(
    searchRepositories: { query in
      let url = URL(
        string: "https://api.github.com/search/repositories?q=\(query)&sort=stars"
      )!
      var request = URLRequest(url: url)
      request.setValue(
        "Bearer \(token)",
        forHTTPHeaderField: "Authorization"
      )
      let (data, _) = try await URLSession.shared.data(for: request)
      let repositories = try jsonDecoder.decode(
        GithubSearchResult.self,
        from: data
      ).items
      return repositories
    }
  )
}

private let token = "INPUT YOUR PERSONAL ACCESS TOKEN"

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}()
