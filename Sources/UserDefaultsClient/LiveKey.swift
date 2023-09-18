import Dependencies
import Foundation

extension UserDefaultsClient: DependencyKey {
  public static let liveValue: Self = {
    let defaults = { UserDefaults(suiteName: "group.tcaworkshop")! }
    return Self(
      dataForKey: { defaults().data(forKey: $0) },
      setData: { defaults().set($0, forKey: $1) }
    )
  }()
}
