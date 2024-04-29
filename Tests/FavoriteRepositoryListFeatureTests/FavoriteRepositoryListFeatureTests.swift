import ComposableArchitecture
import Entity
import XCTest

@testable import FavoriteRepositoryListFeature

@MainActor
final class FavoriteRepositoryListFeatureTests: XCTestCase {
  func testOnAppear() async {
    let repositories: [Repository] = (1...10).map { .mock(id: $0) }
    @Shared(.favoriteRepositories) var favoriteRepositories = .init(
      uniqueElements: repositories
    )
    let store = TestStore(
      initialState: FavoriteRepositoryList.State()
    ) {
      FavoriteRepositoryList()
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
    @Shared(.favoriteRepositories) var favoriteRepositories = [
      .mock(id: 1)
    ]
    let store = TestStore(
      initialState: FavoriteRepositoryList.State()
    ) {
      FavoriteRepositoryList()
    }

    await store.send(.onAppear) {
      $0.repositoryRows = [
        .init(repository: .mock(id: 1)),
      ]
    }
    await store.send(\.repositoryRows[id: 1].delegate.rowTapped, .mock(id: 1)) {
      $0.path = .init(
        [
          .repositoryDetail(.init(repository: .mock(id: 1)))
        ]
      )
    }
  }

  func testRepositoryRowDeleted() async {
    @Shared(.favoriteRepositories) var favoriteRepositories = [
      .mock(id: 1)
    ]
    let store = TestStore(
      initialState: FavoriteRepositoryList.State()
    ) {
      FavoriteRepositoryList()
    }

    await store.send(.onAppear) {
      $0.repositoryRows = [
        .init(repository: .mock(id: 1)),
      ]
    }
    await store.send(.delete([0])) {
      $0.favoriteRepositories = []
      $0.repositoryRows = []
    }
  }
}
