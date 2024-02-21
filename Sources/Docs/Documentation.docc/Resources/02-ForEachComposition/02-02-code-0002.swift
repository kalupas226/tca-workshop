import ComposableArchitecture
import Entity
import SwiftUI

struct RepositoryRowView: View {
  let store: StoreOf<RepositoryRow>

  init(store: StoreOf<RepositoryRow>) {
    self.store = store
  }

  var body: some View {
    Button {
    } label: {
      VStack(alignment: .leading, spacing: 8) {
        Text(repository.fullName)
          .font(.title2.bold())
        Text(repository.description ?? "")
          .font(.body)
          .lineLimit(2)
        HStack(alignment: .center, spacing: 32) {
          Label(
            title: {
              Text("\(repository.stargazersCount)")
                .font(.callout)
            },
            icon: {
              Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            }
          )
          Label(
            title: {
              Text(repository.language ?? "")
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
