import CasePaths
import ComposableArchitecture
import Entity
import Foundation
import IdentifiedCollections
import SwiftUI

public struct RepositoryListView: View {
  let store: StoreOf<RepositoryList>
  
  public init(store: StoreOf<RepositoryList>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Group {
        if viewStore.isLoading {
          ProgressView()
        } else {
          List {
            ForEachStore(
              store.scope(
                state: \.repositoryRows,
                action: { .repositoryRow(id: $0, action: $1) }
              ),
              content: RepositoryRowView.init(store:)
            )
          }
        }
      }
      .onAppear {
        viewStore.send(.onAppear)
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
    }
  )
}
