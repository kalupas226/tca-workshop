import Dependencies
import Foundation
import XCTestDynamicOverlay

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
  
  public static let testValue = Self()
}
