import ComposableArchitecture
import Entity
import XCTest

@testable import RepositoryDetailFeature

@MainActor
final class RepositoryDetailFeatureTests: XCTestCase {
  func testRepositoryIsFavorited() async {
    let repository = Repository.mock(id: 1)
    @Shared(.favoriteRepositories) var favoriteRepositories = [
      repository
    ]
    favoriteRepositories = [repository]

    let store = TestStore(
      initialState: RepositoryDetail.State(
        repository: repository
      )
    ) {
      RepositoryDetail()
    }

    await store.send(.onAppear) {
      $0.isFavoriteRepository = true
    }
    
    await store.send(.favoriteButtonTapped) {
      $0.favoriteRepositories = []
      $0.isFavoriteRepository = false
    }
  }
  
  func testRepositoryIsNotFavorited() async {
    @Shared(.favoriteRepositories) var favoriteRepositories = []
    favoriteRepositories = []

    let store = TestStore(
      initialState: RepositoryDetail.State(
        repository: .mock(id: 2)
      )
    ) {
      RepositoryDetail()
    }

    await store.send(.onAppear)
    
    await store.send(.favoriteButtonTapped) {
      $0.favoriteRepositories = [
        .mock(id: 2)
      ]
      $0.isFavoriteRepository = true
    }
  }
}
