import Foundation
import OpenAPIRuntime

/// Mapping extensions between OpenAPI generated types and Domain entities
/// Generated types (Components.Schemas.User) are available after build

extension Components.Schemas.User {
    /// Convert OpenAPI generated User to Domain User entity
    /// - Returns: Domain layer User
    func toDomain() -> User {
        User(
            id: id,
            idAlias: idAlias,
            name: name,
            avatarUrl: avatarUrl,
            createdAt: createdAt
        )
    }
}

extension User {
    /// Convert Domain User to OpenAPI CreateUserRequest
    /// - Returns: OpenAPI CreateUserRequest schema
    func toCreateRequest() -> Components.Schemas.CreateUserRequest {
        Components.Schemas.CreateUserRequest(
            name: name,
            avatarUrl: avatarUrl
        )
    }
}
