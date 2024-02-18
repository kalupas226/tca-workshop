import ComposableArchitecture
import Entity
import Foundation
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
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}
