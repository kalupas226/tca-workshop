import CasePaths
import ComposableArchitecture
import Entity
import Foundation
import IdentifiedCollections
import SwiftUI

public struct RepositoryList: Reducer {
  public struct State: Equatable {
    var repositoryRows: IdentifiedArrayOf<RepositoryRow.State> = []
    var isLoading: Bool = false
    @BindingState var query: String = ""

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onAppear
    case searchRepositoriesResponse(TaskResult<[Repository]>)
    case repositoryRow(id: RepositoryRow.State.ID, action: RepositoryRow.Action)
    case binding(BindingAction<State>)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return searchRepositories(by: "composable")
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
      case .repositoryRow:
        return .none
      case .binding(\.$query):
        guard !state.query.isEmpty else {
          return .none
        }

        state.isLoading = true

        return searchRepositories(by: state.query)
      case .binding:
        return .none
      }
    }
    .forEach(\.repositoryRows, action: /Action.repositoryRow(id:action:)) {
      RepositoryRow()
    }
  }

  func searchRepositories(by query: String) -> Effect<Action> {
    .run { send in
      await send(
        .searchRepositoriesResponse(
          TaskResult {
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
  }

  private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()
}
