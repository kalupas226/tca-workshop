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

public struct RepositoryListView: View {
  @Bindable var store: StoreOf<RepositoryList>

  public init(store: StoreOf<RepositoryList>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
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
      .navigationTitle("Repositories")
      .searchable(
        text: $store.query,
        placement: .navigationBarDrawer,
        prompt: "Input query"
      )
      .alert(
        $store.scope(
          state: \.destination?.alert,
          action: \.destination.alert
        )
      )
      // navigationDestination の削除
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
        try await Task.sleep(for: .seconds(0.3))
        return (1...20).map { .mock(id: $0) }
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
