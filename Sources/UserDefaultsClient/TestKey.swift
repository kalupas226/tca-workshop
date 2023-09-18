import Dependencies
import Foundation

extension DependencyValues {
  public var userDefaultsClient: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}

extension UserDefaultsClient: TestDependencyKey {
  public static let previewValue = Self(
    dataForKey: { _ in nil },
    setData: { _, _ in }
  )
  
  public static let testValue = Self(
    dataForKey: unimplemented("\(Self.self).dataForKey"),
    setData: unimplemented("\(Self.self).setData")
  )
}
