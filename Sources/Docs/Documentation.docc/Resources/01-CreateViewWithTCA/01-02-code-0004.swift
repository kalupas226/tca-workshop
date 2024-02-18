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
        List {
          ForEach(store.repositories, id: \.id) { repository in
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
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}
