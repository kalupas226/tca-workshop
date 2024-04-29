import CasePaths
import ComposableArchitecture
import Dependencies
import Entity
import IdentifiedCollections
import PersistenceKeys
import RepositoryDetailFeature
import SwiftUI

@Reducer
public struct FavoriteRepositoryList {
  @ObservableState
  public struct State: Equatable {
    @Shared(.favoriteRepositories) var favoriteRepositories
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

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.repositoryRows = .init(
          uniqueElements: state.favoriteRepositories.map {
            .init(repository: $0)
          }
        )
        return .none
      case let .delete(indexSet):
        state.repositoryRows.remove(atOffsets: indexSet)
        state.favoriteRepositories.remove(atOffsets: indexSet)
        return .none
      case let .repositoryRows(.element(_, .delegate(.rowTapped(repository)))):
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
  @Shared(.favoriteRepositories) var favoriteRepositories = .init(
    uniqueElements: (1...10).map(Repository.mock(id:))
  )
  return FavoriteRepositoryListView(
    store: .init(
      initialState: FavoriteRepositoryList.State()
    ) {
      FavoriteRepositoryList()
    }
  )
}

