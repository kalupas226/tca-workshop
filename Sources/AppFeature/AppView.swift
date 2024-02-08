import CasePaths
import ComposableArchitecture
import FavoriteRepositoryListFeature
import RepositoryListFeature
import SwiftUI

@Reducer
public struct App {
  @ObservableState
  public struct State: Equatable {
    var repositoryList = RepositoryList.State()
    var favoriteRepositoryList = FavoriteRepositoryList.State()
    
    public init() {}
  }
  
  public enum Action {
    case repositoryList(RepositoryList.Action)
    case favoriteRepositoryList(FavoriteRepositoryList.Action)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Scope(state: \.repositoryList, action: \.repositoryList) {
      RepositoryList()
    }
    Scope(state: \.favoriteRepositoryList, action: \.favoriteRepositoryList) {
      FavoriteRepositoryList()
    }
  }
}

public struct AppView: View {
  let store: StoreOf<App>

  public init(store: StoreOf<App>) {
    self.store = store
  }
  
  public var body: some View {
    TabView {
      RepositoryListView(
        store: store.scope(
          state: \.repositoryList,
          action: \.repositoryList
        )
      )
      .tabItem {
        Label("Search", systemImage: "magnifyingglass")
      }
      FavoriteRepositoryListView(
        store: store.scope(
          state: \.favoriteRepositoryList,
          action: \.favoriteRepositoryList
        )
      )
      .tabItem {
        Label("Favorite", systemImage: "heart.fill")
      }
    }
  }
}

#Preview {
  AppView(
    store: .init(
      initialState: App.State()
    ) {
      App()
    }
  )
}
