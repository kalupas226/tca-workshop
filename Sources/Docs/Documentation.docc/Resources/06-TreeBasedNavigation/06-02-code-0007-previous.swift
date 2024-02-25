import ComposableArchitecture
import Entity

@Reducer
public struct RepositoryRow {
  @ObservableState
  public struct State: Equatable, Identifiable {
    public var id: Int { repository.id }
    let repository: Repository
  }

  public enum Action {
    case rowTapped
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .rowTapped:
        return .none
      }
    }
  }
}
