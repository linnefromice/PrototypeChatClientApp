import Foundation
import OpenAPIRuntime

/// Real implementation using OpenAPI generated Client
class UserRepository: UserRepositoryProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func fetchUser(id: String) async throws -> User {
        // OpenAPI generated method will be used after build
        // Temporary implementation using mock
        throw NetworkError.unknown
    }

    func fetchUsers() async throws -> [User] {
        // OpenAPI generated method will be used after build
        // Temporary implementation using mock
        throw NetworkError.unknown
    }

    func createUser(name: String, avatarUrl: String?) async throws -> User {
        // OpenAPI generated method will be used after build
        // Temporary implementation using mock
        throw NetworkError.unknown
    }
}

// Note: MockUserRepository is defined in Features/Authentication/Data/Repositories/MockUserRepository.swift
