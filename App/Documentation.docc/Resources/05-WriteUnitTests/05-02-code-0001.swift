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
      $0.gitHubAPIClient.searchRepositories = { _ in
        response
      }
    }

    await store.send(.onAppear) {
      $0.isLoading = true
    }
    await store.receive(.searchRepositoriesResponse(.success(response))) {
      $0.repositoryRows = .init(
        uniqueElements: response.map {
          .init(repository: $0)
        }
      )
      $0.isLoading = false
    }
  }
  
  func testQueryChanged() async {
    let response: [Repository] = (1...10).map {
      .mock(id: $0)
    }

    let store = TestStore(
      initialState: RepositoryList.State()
    ) {
      RepositoryList()
    } withDependencies: {
      $0.gitHubAPIClient.searchRepositories = { _ in response }
    }
  }
}
