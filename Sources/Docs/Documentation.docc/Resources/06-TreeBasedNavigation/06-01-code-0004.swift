import CasePaths
import ComposableArchitecture
import Dependencies
import Entity
import Foundation
import IdentifiedCollections
import SwiftUI
import SwiftUINavigationCore

public struct RepositoryListView: View {
  let store: StoreOf<RepositoryList>

  public init(store: StoreOf<RepositoryList>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      WithViewStore(store, observe: { $0 }) { viewStore in
        Group {
          if viewStore.isLoading {
            ProgressView()
          } else {
            List {
              ForEachStore(
                store.scope(
                  state: \.repositoryRows,
                  action:  { .repositoryRow(id: $0, action: $1) }
                ),
                content: RepositoryRowView.init(store:)
              )
            }
          }
        }
        .onAppear {
          viewStore.send(.onAppear)
        }
        .navigationTitle("Repositories")
        .searchable(
          text: viewStore.$query,
          placement: .navigationBarDrawer,
          prompt: "Input query"
        )
        .alert(
          store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
          )
        )
      }
    }
  }
}

#Preview {
  RepositoryListView(
    store: .init(
      initialState: RepositoryList.State()
    ) {
      RepositoryList()
    } withDependencies: {
      $0.gitHubAPIClient.searchRepositories = { _ in
        try await Task.sleep(for: .seconds(0.3))
        return (1...20).map { .mock(id: $0) }
      }
    }
  )
}
