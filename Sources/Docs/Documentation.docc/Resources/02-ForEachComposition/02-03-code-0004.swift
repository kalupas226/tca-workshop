import CasePaths
import ComposableArchitecture
import Entity
import Foundation
import IdentifiedCollections
import SwiftUI

@Reducer
public struct RepositoryList {
  @ObservableState
  public struct State: Equatable {
    var repositoryRows: IdentifiedArrayOf<RepositoryRow.State> = []
    var isLoading: Bool = false

    public init() {}
  }

  public enum Action {
    case onAppear
    case searchRepositoriesResponse(Result<[Repository], Error>)
    case repositoryRows(IdentifiedActionOf<RepositoryRow>)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .run { send in
          await send(
            .searchRepositoriesResponse(
              Result {
                let query = "composable"
                let url = URL(
                  string: "https://api.github.com/search/repositories?q=\(query)&sort=stars"
                )!
                var request = URLRequest(url: url)
                if let token = Bundle.main.infoDictionary?["GitHubPersonalAccessToken"] as? String {
                  request.setValue(
                    "Bearer \(token)",
                    forHTTPHeaderField: "Authorization"
                  )
                }
                let (data, _) = try await URLSession.shared.data(for: request)
                let repositories = try jsonDecoder.decode(
                  GithubSearchResult.self,
                  from: data
                ).items
                return repositories
              }
            )
          )
        }
      case let .searchRepositoriesResponse(result):
        state.isLoading = false

        switch result {
        case let .success(response):
          state.repositoryRows = .init(
            uniqueElements: response.map {
              .init(repository: $0)
            }
          )
          return .none
        case .failure:
          // TODO: Handling error
          return .none
        }
      case .repositoryRows:
        return .none
      }
    }
    .forEach(\.repositoryRows, action: \.repositoryRows) {
      RepositoryRow()
    }
  }

  private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()
}
