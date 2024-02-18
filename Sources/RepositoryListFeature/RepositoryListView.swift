import CasePaths
import ComposableArchitecture
import Dependencies
import Entity
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
    case queryChangeDebounced
    case searchRepositoriesResponse(Result<[Repository], Error>)
    case repositoryRows(IdentifiedActionOf<RepositoryRow>)
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
    case path(StackAction<Path.State, Path.Action>)
  }

  @Dependency(\.gitHubAPIClient) var gitHubAPIClient
  @Dependency(\.mainQueue) var mainQueue
  
  public init() {}

  private enum CancelID {
    case response
  }

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce<State, Action> { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true

        return .run { send in
          await send(
            .searchRepositoriesResponse(
              Result {
                try await gitHubAPIClient.searchRepositories("composable")
              }
            )
          )
        }
      case let .searchRepositoriesResponse(result):
        state.isLoading = false

        switch result {
        case let .success(repositories):
          state.repositoryRows = .init(
            uniqueElements: repositories.map {
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

        return .run { [query = state.query] send in
          await send(
            .searchRepositoriesResponse(
              Result {
                try await gitHubAPIClient.searchRepositories(query)
              }
            )
          )
        }
      case .binding, .destination, .path:
        return .none
      }
    }
    .forEach(\.repositoryRows, action: \.repositoryRows) {
      RepositoryRow()
    }
    .forEach(\.path, action: \.path)
    .ifLet(\.$destination, action: \.destination)
  }
}

extension RepositoryList {
  @Reducer(state: .equatable)
  public enum Destination {
    case alert(AlertState<Alert>)

    public enum Alert: Equatable {}
  }

  @Reducer(state: .equatable)
  public enum Path {
    case repositoryDetail(RepositoryDetail)
  }
}

extension AlertState where Action == RepositoryList.Destination.Alert {
  static let networkError = Self {
    TextState("Network Error")
  } message: {
    TextState("Failed to fetch data.")
  }
}

public struct RepositoryListView: View {
  @Bindable var store: StoreOf<RepositoryList>

  public init(store: StoreOf<RepositoryList>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(
      path: $store.scope(
        state: \.path,
        action: \.path
      )
    ) {
      Group {
        if store.isLoading {
          ProgressView()
        } else {
          List {
            ForEach(
              store.scope(
                state: \.repositoryRows,
                action: \.repositoryRows
              ),
              content: RepositoryRowView.init(store:)
            )
          }
        }
      }
      .onAppear {
        store.send(.onAppear)
      }
      .navigationTitle("Search Repositories")
      .alert(
        $store.scope(
          state: \.destination?.alert,
          action: \.destination.alert
        )
      )
      .searchable(
        text: $store.query,
        placement: .navigationBarDrawer,
        prompt: "Input query"
      )
    } destination: { store in
      switch store.case {
      case let .repositoryDetail(store):
        RepositoryDetailView(store: store)
      }
    }
  }
}

#Preview("API Succeeded") {
  RepositoryListView(
    store: .init(
      initialState: RepositoryList.State()
    ) {
      RepositoryList()
    } withDependencies: {
      $0.gitHubAPIClient.searchRepositories = { @Sendable _ in
        (1...20).map { .mock(id: $0) }
      }
    }
  )
}

#Preview("API Failed") {
  enum PreviewError: Error {
    case fetchFailed
  }
  return RepositoryListView(
    store: .init(
      initialState: RepositoryList.State()
    ) {
      RepositoryList()
    } withDependencies: {
      $0.gitHubAPIClient.searchRepositories = { @Sendable _ in
        throw PreviewError.fetchFailed
      }
    }
  )
}
