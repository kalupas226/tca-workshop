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
    case delegate(Delegate)
    
    public enum Delegate {
      case rowTapped
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .rowTapped:
        return .send(.delegate(.rowTapped))
      case .delegate:
        return .none
      }
    }
  }
}
