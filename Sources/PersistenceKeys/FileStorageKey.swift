import ComposableArchitecture
import Entity
import Foundation

extension PersistenceReaderKey
where Self == PersistenceKeyDefault<FileStorageKey<IdentifiedArrayOf<Repository>>> {
  public static var favoriteRepositories: Self {
    PersistenceKeyDefault(
      .fileStorage(.documentsDirectory.appending(component: "favorite-repositories.json")),
      []
    )
  }
}
