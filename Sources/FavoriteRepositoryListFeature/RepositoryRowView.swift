import ComposableArchitecture
import Entity
import Foundation
import SwiftUI

@Reducer
public struct RepositoryRow {
  @ObservableState
  public struct State: Equatable, Identifiable {
    public var id: Int { repository.id }

    let repository: Repository

    public init(repository: Repository) {
      self.repository = repository
    }
  }

  public enum Action {
    case rowTapped
    case delegate(Delegate)
    
    @CasePathable
    public enum Delegate {
      case rowTapped(Repository)
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .rowTapped:
        return .send(.delegate(.rowTapped(state.repository)))
      case .delegate:
        return .none
      }
    }
  }
}

struct RepositoryRowView: View {
  let store: StoreOf<RepositoryRow>

  var body: some View {
    Button {
      store.send(.rowTapped)
    } label: {
      VStack(alignment: .leading, spacing: 8) {
        Text(store.repository.fullName)
          .font(.title2.bold())
        Text(store.repository.description ?? "")
          .font(.body)
          .lineLimit(2)
        HStack(alignment: .center, spacing: 32) {
          Label(
            title: {
              Text("\(store.repository.stargazersCount)")
                .font(.callout)
            },
            icon: {
              Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            }
          )
          Label(
            title: {
              Text(store.repository.language ?? "")
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

#Preview {
  RepositoryRowView(
    store: .init(
      initialState: RepositoryRow.State(
        repository: .mock(id: 1)
      )
    ) {
      RepositoryRow()
    }
  )
  .padding()
}
