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
}
