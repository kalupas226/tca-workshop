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
      Button {
        viewStore.send(.rowTapped)
      } label: {
        VStack(alignment: .leading, spacing: 8) {
          Text(viewStore.repository.fullName)
            .font(.title2.bold())
          Text(viewStore.repository.description ?? "")
            .font(.body)
            .lineLimit(2)
          HStack(alignment: .center, spacing: 32) {
            Label(
              title: {
                Text("\(viewStore.repository.stargazersCount)")
                  .font(.callout)
              },
              icon: {
                Image(systemName: "star.fill")
                  .foregroundStyle(.yellow)
              }
            )
            Label(
              title: {
                Text(viewStore.repository.language ?? "")
                  .font(.callout)
              },
              icon: {
                Image(systemName: "text.word.spacing")
                  .foregroundStyle(.gray)
              }
            )
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .buttonStyle(.plain)
    }
  }
}
