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
  }

  public init() {}
}
