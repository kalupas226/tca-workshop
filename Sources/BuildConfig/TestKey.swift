import Dependencies
import XCTestDynamicOverlay

extension DependencyValues {
  public var buildConfig: BuildConfig {
    get { self[BuildConfig.self] }
    set { self[BuildConfig.self] = newValue }
  }
}

extension BuildConfig: TestDependencyKey {
  public static let previewValue = Self()
  
  public static let testValue = Self()
}
