// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "TCAWorkshop",
  platforms: [.iOS(.v16)],
  products: [
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "RepositoryListFeature", targets: ["RepositoryListFeature"]),
    .library(name: "RepositoryDetailFeature", targets: ["RepositoryDetailFeature"]),
    .library(name: "FavoriteRepositoryListFeature", targets: ["FavoriteRepositoryListFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.2"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        "FavoriteRepositoryListFeature",
        "RepositoryListFeature",
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
      name: "Entity"
    ),
    .target(
      name: "RepositoryListFeature",
      dependencies: [
        "Entity",
        "GitHubAPIClient",
        "RepositoryDetailFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
      ]
    ),
    .testTarget(
      name: "RepositoryListFeatureTests",
      dependencies: [
        "RepositoryListFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "RepositoryDetailFeature",
      dependencies: [
        "Entity",
        "GitHubAPIClient",
        "UserDefaultsClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        "UserDefaultsClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
    .target(
      name: "UserDefaultsClient",
      dependencies: [
        "Entity",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
  ]
)
