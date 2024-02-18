import CasePaths
import ComposableArchitecture
import Dependencies
import Entity
import IdentifiedCollections
import RepositoryDetailFeature
import SwiftUI
import UserDefaultsClient

@Reducer
public struct FavoriteRepositoryList {
  @ObservableState
  public struct State: Equatable {
    var repositoryRows: IdentifiedArrayOf<RepositoryRow.State> = []
    var path = StackState<Path.State>()
    
    public init() {}
  }

  public enum Action {
    case onAppear
    case delete(IndexSet)
    case repositoryRows(IdentifiedActionOf<RepositoryRow>)
    case path(StackAction<Path.State, Path.Action>)
  }
  
  @Dependency(\.userDefaultsClient) var userDefaultsClient

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
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
      case let .repositoryRows(.element(_, action: .delegate(.rowTapped(repository)))):
        state.path.append(
          .repositoryDetail(
            .init(repository: repository)
          )
        )
        return .none
      case .repositoryRows:
        return .none
      case .path:
        return .none
      }
    }
    .forEach(\.repositoryRows, action: \.repositoryRows) {
      RepositoryRow()
    }
    .forEach(\.path, action: \.path)
  }
  
  @Reducer(state: .equatable)
  public enum Path {
    case repositoryDetail(RepositoryDetail)
  }
}

public struct FavoriteRepositoryListView: View {
  @Bindable var store: StoreOf<FavoriteRepositoryList>

  public init(store: StoreOf<FavoriteRepositoryList>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(
      path: $store.scope(
        state: \.path,
        action: \.path
      )
    ) {
      List {
        ForEach(
          store.scope(
            state: \.repositoryRows,
            action: \.repositoryRows
          ),
          content: RepositoryRowView.init(store:)
        )
        .onDelete {
          store.send(.delete($0))
        }
      }
      .navigationTitle("Favorite Repositories")
      .onAppear {
        store.send(.onAppear)
      }
    } destination: { store in
      switch store.case {
      case let .repositoryDetail(store):
        RepositoryDetailView(store: store)
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

