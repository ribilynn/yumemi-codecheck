import Foundation

/// Represents the result of searching repositories.
struct RepositorySearchResult: Decodable {
    let totalCount: Int
    let repositories: [Repository]

    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case repositories = "items"
    }
}

extension RepositorySearchResult {
    /// Represents a github repository within a `RepositoriesSearchResult`.
    struct Repository: Identifiable, Decodable {

        /// Represents an owner of a repository.
        struct Owner: Identifiable, Decodable {
            let id: Int
            /// The name of this owner.
            let login: String
            @URLDecoder var avatarUrl: URL?

            private enum CodingKeys: String, CodingKey {
                case login
                case id
                case avatarUrl = "avatar_url"
            }
        }

        let id: Int
        let name: String
        let fullName: String
        let language: String?
        let owner: Owner
        let description: String?
        let stargazersCount: Int

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case fullName = "full_name"
            case language
            case owner
            case description
            case stargazersCount = "stargazers_count"
        }
    }
}
