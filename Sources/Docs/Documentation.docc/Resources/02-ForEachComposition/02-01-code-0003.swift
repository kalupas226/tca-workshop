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

  }

  public var body: some ReducerOf<Self> {

  }
}
