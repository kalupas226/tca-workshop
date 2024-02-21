import CasePaths
import ComposableArchitecture
import Entity
import Foundation
import IdentifiedCollections
import SwiftUI

public struct RepositoryListView: View {
  @Bindable var store: StoreOf<RepositoryList>

  public init(store: StoreOf<RepositoryList>) {
    self.store = store
  }

  public var body: some View {
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
  }
}

#Preview {
  RepositoryListView(
    store: .init(
      initialState: RepositoryList.State()
    ) {
      RepositoryList()
    }
  )
}
