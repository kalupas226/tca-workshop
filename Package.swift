// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "TCAWorkshop",
  platforms: [.iOS(.v17), .macOS(.v10_15)],
  products: [
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "Docs", targets: ["Docs"]),
    .library(name: "RepositoryListFeature", targets: ["RepositoryListFeature"]),
    .library(name: "RepositoryDetailFeature", targets: ["RepositoryDetailFeature"]),
    .library(name: "FavoriteRepositoryListFeature", targets: ["FavoriteRepositoryListFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.2.3"),
    .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.1"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "1.2.1"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        "FavoriteRepositoryListFeature",
        "RepositoryListFeature",
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        "AppFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "BuildConfig",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "Docs"
    ),
    .target(
      name: "Entity"
    ),
    .target(
      name: "RepositoryListFeature",
      dependencies: [
        "Entity",
        "GitHubAPIClient",
        "RepositoryDetailFeature",
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        .product(name: "SwiftUINavigationCore", package: "swiftui-navigation"),
      ]
    ),
    .testTarget(
      name: "RepositoryListFeatureTests",
      dependencies: [
        "RepositoryListFeature",
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "RepositoryDetailFeature",
      dependencies: [
        "Entity",
        "GitHubAPIClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .testTarget(
      name: "RepositoryDetailFeatureTests",
      dependencies: [
        "Entity",
        "RepositoryDetailFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "FavoriteRepositoryListFeature",
      dependencies: [
        "Entity",
        "RepositoryDetailFeature",
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
      ]
    ),
    .testTarget(
      name: "FavoriteRepositoryListFeatureTests",
      dependencies: [
        "FavoriteRepositoryListFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "GitHubAPIClient",
      dependencies: [
        "BuildConfig",
        "Entity",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
  ]
)
