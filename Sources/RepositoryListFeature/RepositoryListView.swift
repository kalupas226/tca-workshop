import ComposableArchitecture
import Dependencies
import Entity
import GitHubAPIClient
import IdentifiedCollections
import RepositoryDetailFeature
import SwiftUI

public struct RepositoryList: Reducer {
  public struct State: Equatable {
    var repositoryRows: IdentifiedArrayOf<RepositoryRow.State> = []
    var isLoading: Bool = false
    @BindingState var query: String = ""
    @PresentationState var alert: AlertState<Action.Alert>?
    var path = StackState<Path.State>()

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onAppear
    case queryChangeDebounced
    case searchRepositoriesResponse(TaskResult<[Repository]>)
    case repositoryRows(id: RepositoryRow.State.ID, action: RepositoryRow.Action)
    case binding(BindingAction<State>)
    case alert(PresentationAction<Alert>)
    case path(StackAction<Path.State, Path.Action>)

    public enum Alert: Equatable {}
  }

  @Dependency(\.continuousClock) var clock
  @Dependency(\.gitHubAPIClient) var gitHubAPIClient
  
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
              TaskResult {
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
          state.alert = .networkError
          return .none
        }
      case let .repositoryRows(id: _, action: .delegate(.openRepositoryDetail(repository))):
        state.path.append(
          .repositoryDetail(
            .init(repository: repository)
          )
        )
        return .none
      case .repositoryRows:
        return .none
      case .binding(\.$query):
        return .run { send in
          try await withTaskCancellation(id: CancelID.response, cancelInFlight: true) {
            try await clock.sleep(for: .seconds(0.3))
            await send(.queryChangeDebounced)
          }
        }
      case .queryChangeDebounced:
        guard !state.query.isEmpty else {
          return .none
        }

        state.isLoading = true

        return .run { [query = state.query] send in
          await send(
            .searchRepositoriesResponse(
              TaskResult {
                try await gitHubAPIClient.searchRepositories(query)
              }
            )
          )
        }
      case .binding, .alert, .path:
        return .none
      }
    }
    .forEach(\.repositoryRows, action: /Action.repositoryRows(id:action:)) {
      RepositoryRow()
    }
    .forEach(\.path, action: /Action.path) {
      Path()
    }
  }

  public struct Path: Reducer {
    public enum State: Equatable {
      case repositoryDetail(RepositoryDetail.State)
    }

    public enum Action: Equatable {
      case repositoryDetail(RepositoryDetail.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: /State.repositoryDetail, action: /Action.repositoryDetail) {
        RepositoryDetail()
      }
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

public struct RepositoryListView: View {
  let store: StoreOf<RepositoryList>

  public init(store: StoreOf<RepositoryList>) {
    self.store = store
  }

  public var body: some View {
    NavigationStackStore(
      store.scope(
        state: \.path,
        action: { .path($0) }
      )
    ) {
      WithViewStore(store, observe: { $0 }) { viewStore in
        Group {
          if viewStore.isLoading {
            ProgressView()
          } else {
            List {
              ForEachStore(
                store.scope(
                  state: \.repositoryRows,
                  action: RepositoryList.Action.repositoryRows(id:action:)
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
          store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
          )
        )
        .searchable(
          text: viewStore.$query,
          placement: .navigationBarDrawer,
          prompt: "Input query"
        )
      }
    } destination: {
      switch $0 {
      case .repositoryDetail:
        CaseLet(
          /RepositoryList.Path.State.repositoryDetail,
           action: RepositoryList.Path.Action.repositoryDetail,
           then: RepositoryDetailView.init(store:)
        )
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
      $0.gitHubAPIClient.searchRepositories = { _ in
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
      $0.gitHubAPIClient.searchRepositories = { _ in
        throw PreviewError.fetchFailed
      }
    }
  )
}
