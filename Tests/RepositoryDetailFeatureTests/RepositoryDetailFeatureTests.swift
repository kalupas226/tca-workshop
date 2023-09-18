import ComposableArchitecture
import Entity
import XCTest

@testable import RepositoryDetailFeature

@MainActor
final class RepositoryDetailFeatureTests: XCTestCase {
  func testRepositoryIsFavorited() async {
    let repository = Repository.mock(id: 1)
    let store = TestStore(
      initialState: RepositoryDetail.State(
        repository: repository
      )
    ) {
      RepositoryDetail()
    } withDependencies: {
      $0.userDefaultsClient.dataForKey = { key in
        XCTAssertNoDifference(key, "favoriteRepositories")
        let data = try! JSONEncoder().encode([repository])
        return data
      }
      $0.userDefaultsClient.setData = { data, key in
        XCTAssertNoDifference(key, "favoriteRepositories")
        XCTAssertNoDifference([], try! JSONDecoder().decode([Repository].self, from: data!))
      }
    }

    await store.send(.onAppear) {
      $0.isFavoriteRepository = true
    }
    
    await store.send(.favoriteButtonTapped) {
      $0.isFavoriteRepository = false
    }
  }
  
  func testRepositoryIsNotFavorited() async {
    let store = TestStore(
      initialState: RepositoryDetail.State(
        repository: .mock(id: 2)
      )
    ) {
      RepositoryDetail()
    } withDependencies: {
      $0.userDefaultsClient.dataForKey = { key in
        XCTAssertNoDifference(key, "favoriteRepositories")
        let repository = Repository.mock(id: 1)
        let data = try! JSONEncoder().encode([repository])
        return data
      }
      $0.userDefaultsClient.setData = { data, key in
        XCTAssertNoDifference(key, "favoriteRepositories")
        let repositories: [Repository] = [
          .mock(id: 1),
          .mock(id: 2),
        ]
        XCTAssertNoDifference(repositories, try! JSONDecoder().decode([Repository].self, from: data!))
      }
    }
    
    await store.send(.onAppear)
    
    await store.send(.favoriteButtonTapped) {
      $0.isFavoriteRepository = true
    }
  }
}
