import ComposableArchitecture
import Entity
import SwiftUI

struct RepositoryRowView: View {
  let store: StoreOf<RepositoryRow>

  init(store: StoreOf<RepositoryRow>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
    }
  }
}
