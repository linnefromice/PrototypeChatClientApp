import Foundation
import OpenAPIRuntime

/// Real implementation using OpenAPI generated Client
class UserRepository: UserRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchUser(id: String) async throws -> User {
        let input = Operations.get_sol_users_sol__lcub_userId_rcub_.Input(
            path: .init(userId: id)
        )

        let response = try await client.get_sol_users_sol__lcub_userId_rcub_(input)

        switch response {
        case .ok(let okResponse):
            let userDTO = try okResponse.body.json
            return userDTO.toDomain()
        case .notFound:
            throw NetworkError.notFound
        case .undocumented(statusCode: let code, _):
            throw NetworkError.from(statusCode: code)
        }
    }

    func fetchUsers() async throws -> [User] {
        let input = Operations.get_sol_users.Input()
        let response = try await client.get_sol_users(input)

        switch response {
        case .ok(let okResponse):
            let users = try okResponse.body.json
            return users.map { $0.toDomain() }
        case .forbidden:
            throw NetworkError.unauthorized
        case .undocumented(statusCode: let code, _):
            throw NetworkError.from(statusCode: code)
        }
    }

    func createUser(name: String, avatarUrl: String?) async throws -> User {
        let input = Operations.post_sol_users.Input(
            body: .json(
                Components.Schemas.CreateUserRequest(
                    name: name,
                    avatarUrl: avatarUrl
                )
            )
        )

        let response = try await client.post_sol_users(input)

        switch response {
        case .created(let createdResponse):
            let userDTO = try createdResponse.body.json
            return userDTO.toDomain()
        case .forbidden:
            throw NetworkError.unauthorized
        case .undocumented(statusCode: let code, _):
            throw NetworkError.from(statusCode: code)
        }
    }
}

// Note: MockUserRepository is defined in Features/Authentication/Data/Repositories/MockUserRepository.swift
