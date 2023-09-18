import Foundation

public struct GithubSearchResult: Codable {
  public let items: [Repository]
}

public struct Repository: Codable, Equatable {
  public let id: Int
  public let fullName: String
  public let description: String?
  public let stargazersCount: Int
  public let language: String?
  public let htmlUrl: URL

  public init(id: Int, fullName: String, description: String?, stargazersCount: Int, language: String?, htmlUrl: URL) {
    self.id = id
    self.fullName = fullName
    self.description = description
    self.stargazersCount = stargazersCount
    self.language = language
    self.htmlUrl = htmlUrl
  }
}

extension Repository {
  public static func mock(id: Int) -> Self {
    .init(
      id: id,
      fullName: "organization/repository-\(id)",
      description: "This is repository \(id)",
      stargazersCount: 5,
      language: "Swift",
      htmlUrl: .init(string: "https://www.apple.com")!
    )
  }
}
