import ComposableArchitecture
import Entity

public struct RepositoryRow: Reducer {
  public struct State: Equatable, Identifiable {
    public var id: Int { repository.id }
    let repository: Repository
  }

  public enum Action: Equatable {
    
  }

  public var body: some ReducerOf<Self> {

  }
}
