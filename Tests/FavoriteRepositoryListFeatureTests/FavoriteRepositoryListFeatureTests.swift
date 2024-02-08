import ComposableArchitecture
import Entity
import XCTest

@testable import FavoriteRepositoryListFeature

@MainActor
final class FavoriteRepositoryListFeatureTests: XCTestCase {
  func testOnAppear() async {
    let repositories: [Repository] = (1...10).map { .mock(id: $0) }
    let store = TestStore(
      initialState: FavoriteRepositoryList.State()
    ) {
      FavoriteRepositoryList()
    } withDependencies: {
      $0.userDefaultsClient.dataForKey = { key in
        XCTAssertNoDifference(key, "favoriteRepositories")
        return try! JSONEncoder().encode(repositories)
      }
    }
    
    await store.send(.onAppear) {
      $0.repositoryRows = .init(
        uniqueElements: repositories.map {
          .init(repository: $0)
        }
      )
    }
  }
  
  func testRepositoryRowTapped() async {
    var state = FavoriteRepositoryList.State()
    state.repositoryRows.append(.init(repository: .mock(id: 1)))
    
    let store = TestStore(
      initialState: state
    ) {
      FavoriteRepositoryList()
    }

    await store.send(.repositoryRows(.element(id: 1, action: .delegate(.rowTapped(.mock(id: 1)))))) {
      $0.path = .init(
        [
          .repositoryDetail(.init(repository: .mock(id: 1)))
        ]
      )
    }
  }
  
  func testRepositoryRowDeleted() async {
    let repository = Repository.mock(id: 1)
    var state = FavoriteRepositoryList.State()
    state.repositoryRows.append(.init(repository: repository))

    let store = TestStore(
      initialState: state
    ) {
      FavoriteRepositoryList()
    } withDependencies: {
      $0.userDefaultsClient.dataForKey = { key in
        XCTAssertNoDifference(key, "favoriteRepositories")
        return try! JSONEncoder().encode([repository])
      }
      $0.userDefaultsClient.setData = { data, key in
        XCTAssertNoDifference(key, "favoriteRepositories")
        XCTAssertNoDifference([], try! JSONDecoder().decode([Repository].self, from: data!))
      }
    }
    
    await store.send(.delete([0])) {
      $0.repositoryRows = []
    }
  }
}
