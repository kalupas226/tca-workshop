import Dependencies
import DependenciesMacros
import Entity
import Foundation

@DependencyClient
public struct UserDefaultsClient {
  public var dataForKey: @Sendable (String) -> Data?
  public var setData: @Sendable (Data?, String) -> Void

  public func getFavoriteRepositories() -> [Repository] {
    guard let data = dataForKey(favoriteRepositories) else {
      return []
    }

    if let repositories = try? JSONDecoder().decode([Repository].self, from: data) {
      return repositories
    }

    return []
  }

  public func addFavoriteRepository(_ repository: Repository) {
    if let data = dataForKey(favoriteRepositories) {
      var repositories = try? JSONDecoder().decode([Repository].self, from: data)
      repositories?.append(repository)
      let data = try? JSONEncoder().encode(repositories)
      setData(data, favoriteRepositories)
    } else {
      let repositories = [repository]
      let data = try? JSONEncoder().encode(repositories)
      setData(data, favoriteRepositories)
    }
  }
  
  public func deleteFavoriteRepository(_ repositoryID: Int) {
    var repositories = getFavoriteRepositories()
    repositories.removeAll(where: { $0.id == repositoryID })

    let data = try? JSONEncoder().encode(repositories)
    setData(data, favoriteRepositories)
  }
}

let favoriteRepositories = "favoriteRepositories"
