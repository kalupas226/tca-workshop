import ComposableArchitecture
import Entity
import Foundation

public struct RepositoryList: Reducer {
  public struct State: Equatable {
    var repositories: [Repository] = []
    var isLoading: Bool = false

    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case searchRepositoriesResponse(TaskResult<[Repository]>)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .none
      }
    }
  }
}
