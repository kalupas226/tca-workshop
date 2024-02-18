import ComposableArchitecture
import Entity
import Foundation

@Reducer
public struct RepositoryList {
  @ObservableState
  public struct State: Equatable {
    var repositories: [Repository] = []
    var isLoading: Bool = false

    public init() {}
  }

  public enum Action {
    case onAppear
    case searchRepositoriesResponse(Result<[Repository], Error>)
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
