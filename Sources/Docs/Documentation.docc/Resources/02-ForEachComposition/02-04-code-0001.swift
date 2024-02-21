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
    Group {
      if store.isLoading {
        ProgressView()
      } else {
        List {
          ForEach(store.repositories, id: \.id) { repository in
            // Button の削除
          }
        }
      }
    }
    .onAppear {
      store.send(.onAppear)
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
