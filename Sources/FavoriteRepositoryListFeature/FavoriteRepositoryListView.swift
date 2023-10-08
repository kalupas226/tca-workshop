import ComposableArchitecture
import Dependencies
import Entity
import IdentifiedCollections
import RepositoryDetailFeature
import SwiftUI
import UserDefaultsClient

public struct FavoriteRepositoryList: Reducer {
  public struct State: Equatable {
    var repositoryRows: IdentifiedArrayOf<RepositoryRow.State> = []
    var path = StackState<Path.State>()
    
    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case delete(IndexSet)
    case repositoryRow(id: RepositoryRow.State.ID, action: RepositoryRow.Action)
    case path(StackAction<Path.State, Path.Action>)
  }
  
  @Dependency(\.userDefaultsClient) var userDefaultsClient

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onAppear:
        state.repositoryRows = .init(
          uniqueElements: userDefaultsClient.getFavoriteRepositories().map {
            .init(repository: $0)
          }
        )
        return .none
      case let .delete(indexSet):
        for index in indexSet {
          userDefaultsClient.deleteFavoriteRepository(
            state.repositoryRows[index].id
          )
          state.repositoryRows.remove(
            id: state.repositoryRows[index].id
          )
        }
        return .none
      case let .repositoryRow(id: _, action: .delegate(.rowTapped(repository))):
        state.path.append(
          .repositoryDetail(
            .init(repository: repository)
          )
        )
        return .none
      case .repositoryRow:
        return .none
      case .path:
        return .none
      }
    }
    .forEach(\.repositoryRows, action: /Action.repositoryRow(id:action:)) {
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

public struct FavoriteRepositoryListView: View {
  let store: StoreOf<FavoriteRepositoryList>
  
  public init(store: StoreOf<FavoriteRepositoryList>) {
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
        List {
          ForEachStore(
            store.scope(
              state: \.repositoryRows,
              action: { .repositoryRow(id: $0, action: $1) }
            ),
            content: RepositoryRowView.init(store:)
          )
          .onDelete {
            viewStore.send(.delete($0))
          }
        }
        .navigationTitle("Favorite Repositories")
        .onAppear {
          viewStore.send(.onAppear)
        }
      }
    } destination: {
      switch $0 {
      case .repositoryDetail:
        CaseLet(
          /FavoriteRepositoryList.Path.State.repositoryDetail,
           action: FavoriteRepositoryList.Path.Action.repositoryDetail,
           then: RepositoryDetailView.init(store:)
        )
      }
    }
  }
}

#Preview {
  FavoriteRepositoryListView(
    store: .init(
      initialState: FavoriteRepositoryList.State()
    ) {
      FavoriteRepositoryList()
    } withDependencies: {
      $0.userDefaultsClient.dataForKey = { _ in
        let mockRepositories: [Repository] = (1...20).map {
          .mock(id: $0)
        }
        return try! JSONEncoder().encode(mockRepositories)
      }
    }
  )
}

