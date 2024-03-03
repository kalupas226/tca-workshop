import CasePaths
import ComposableArchitecture
import Dependencies
import Entity
import Foundation
import GitHubAPIClient
import IdentifiedCollections
import SwiftUI
import SwiftUINavigationCore

@Reducer
public struct RepositoryList {
  @ObservableState
  public struct State: Equatable {
    var repositoryRows: IdentifiedArrayOf<RepositoryRow.State> = []
    var isLoading: Bool = false
    var query: String = ""
    @Presents var alert: AlertState<Action.Alert>?

    public init() {}
  }

  public enum Action: BindableAction {
    case onAppear
    case searchRepositoriesResponse(Result<[Repository], Error>)
    case repositoryRows(IdentifiedActionOf<RepositoryRow>)
    case queryChangeDebounced
    case binding(BindingAction<State>)
    case alert(PresentationAction<Alert>)

    public enum Alert: Equatable {}
  }

  public init() {}

  private enum CancelID {
    case response
  }

  @Dependency(\.gitHubAPIClient) var gitHubAPIClient
  @Dependency(\.mainQueue) var mainQueue

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
          state.alert = .networkError
          return .none
        }
      case .repositoryRows:
        return .none
      case .binding(\.query):
        return .run { send in
          await send(.queryChangeDebounced)
        }
        .debounce(
          id: CancelID.response,
          for: .seconds(0.3),
          scheduler: mainQueue
        )
      case .queryChangeDebounced:
        guard !state.query.isEmpty else {
          return .none
        }

        state.isLoading = true

        return searchRepositories(by: state.query)
      case .binding:
        return .none
      case .alert:
        return .none
      }
    }
    .forEach(\.repositoryRows, action: \.repositoryRows) {
      RepositoryRow()
    }
  }

  func searchRepositories(by query: String) -> Effect<Action> {
    .run { send in
      await send(
        .searchRepositoriesResponse(
          Result {
            try await gitHubAPIClient.searchRepositories(query)
          }
        )
      )
    }
  }
}

extension AlertState where Action == RepositoryList.Action.Alert {
  static let networkError = Self {
    TextState("Network Error")
  } message: {
    TextState("Failed to fetch data.")
  }
}

extension RepositoryList {
  @Reducer
  public enum Destination {

  }
}
