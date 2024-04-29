import CombineSchedulers
import ComposableArchitecture
import Entity
import XCTest

@testable import RepositoryListFeature

@MainActor
final class RepositoryListFeatureTests: XCTestCase {
  func testOnAppear_SearchSucceeded() async {
    let response: [Repository] = (1...10).map {
      .mock(id: $0)
    }

    let store = TestStore(
      initialState: RepositoryList.State()
    ) {
      RepositoryList()
    } withDependencies: {
      $0.gitHubAPIClient.searchRepositories = { @Sendable _ in response }
    }
    
    await store.send(.onAppear) {
      $0.isLoading = true
    }
    await store.receive(\.searchRepositoriesResponse) {
      $0.repositoryRows = .init(
        uniqueElements: response.map {
          .init(repository: $0)
        }
      )
      $0.isLoading = false
    }
  }
  
  func testOnAppear_SearchFailed() async {
    let store = TestStore(
      initialState: RepositoryList.State()
    ) {
      RepositoryList()
    } withDependencies: {
      $0.gitHubAPIClient.searchRepositories = { @Sendable _ in
        throw TestError.search
      }
    }
    
    await store.send(.onAppear) {
      $0.isLoading = true
    }
    await store.receive(\.searchRepositoriesResponse) {
      $0.destination = .alert(.networkError)
      $0.isLoading = false
    }
  }

  func testQueryChanged() async {
    let response: [Repository] = (1...10).map {
      .mock(id: $0)
    }
    let testScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: RepositoryList.State()
    ) {
      RepositoryList()
    } withDependencies: {
      $0.gitHubAPIClient.searchRepositories = { @Sendable _ in response }
      $0.mainQueue = testScheduler.eraseToAnyScheduler()
    }

    await store.send(\.binding.query, "test") {
      $0.query = "test"
    }
    await testScheduler.advance(by: .seconds(0.3))
    await store.receive(\.queryChangeDebounced) {
      $0.isLoading = true
    }
    await store.receive(\.searchRepositoriesResponse) {
      $0.repositoryRows = .init(
        uniqueElements: response.map {
          .init(repository: $0)
        }
      )
      $0.isLoading = false
    }
  }

  func testRepositoryRowTapped() async {
    var state = RepositoryList.State()
    state.repositoryRows.append(
      .init(
        repository: .mock(id: 1)
      )
    )
    let store = TestStore(
      initialState: state
    ) {
      RepositoryList()
    }

    await store.send(\.repositoryRows[id: 1].delegate.rowTapped) {
      $0.path = .init(
        [
          .repositoryDetail(.init(repository: .mock(id: 1)))
        ]
      )
    }
  }
}

private enum TestError: Error {
  case search
}
