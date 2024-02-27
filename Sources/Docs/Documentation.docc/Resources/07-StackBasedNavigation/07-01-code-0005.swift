import CasePaths
import ComposableArchitecture
import Dependencies
import Entity
import Foundation
import GitHubAPIClient
import IdentifiedCollections
import RepositoryDetailFeature
import SwiftUI
import SwiftUINavigationCore

@Reducer
public struct RepositoryList {
  @ObservableState
  public struct State: Equatable {
    var repositoryRows: IdentifiedArrayOf<RepositoryRow.State> = []
    var isLoading: Bool = false
    var query: String = ""
    @Presents var destination: Destination.State?
    var path = StackState<Path.State>()

    public init() {}
  }

  public enum Action: BindableAction {
    case onAppear
    case searchRepositoriesResponse(Result<[Repository]>)
    case repositoryRows(IdentifiedActionOf<RepositoryRow>)
    case queryChangeDebounced
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
    case path(StackAction<Path.State, Path.Action>)
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
          state.destination = .alert(.networkError)
          return .none
        }
      case let .repositoryRows(.element(id, .delegate(.rowTapped))):
        guard let repository = state.repositoryRows[id: id]?.repository
        else { return .none }
        
        state.path.append(
          .repositoryDetail(
            .init(repository: repository)
          )
        )
        return .none
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
      case .destination:
        return .none
      case .path:
        return .none
      }
    }
    .forEach(\.repositoryRows, action: \.repositoryRows) {
      RepositoryRow()
    }
    .ifLet(\.$destination, action: \.destination)
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

extension AlertState where Action == RepositoryList.Destination.Alert {
  static let networkError = Self {
    TextState("Network Error")
  } message: {
    TextState("Failed to fetch data.")
  }
}

extension RepositoryList {
  @Reducer
  public enum Destination {
    case alert(AlertState<Action.Alert>)

    public enum Alert: Equatable {}
  }
  
  @Reducer
  public enum Path {
    case repositoryDetail(RepositoryDetail)
  }
}
