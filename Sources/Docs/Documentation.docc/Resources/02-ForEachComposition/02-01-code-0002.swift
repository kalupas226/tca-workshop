import ComposableArchitecture
import Entity

@Reducer
public struct RepositoryRow {
  @ObservableState
  public struct State: Equatable {
    let repository: Repository
  }

  public enum Action {

  }

  public var body: some ReducerOf<Self> {

  }
}
