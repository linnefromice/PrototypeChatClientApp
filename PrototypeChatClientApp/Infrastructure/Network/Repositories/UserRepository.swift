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

        do {
            let response = try await client.get_sol_users_sol__lcub_userId_rcub_(input)

            switch response {
            case .ok(let okResponse):
                let userDTO = try okResponse.body.json
                return userDTO.toDomain()
            case .notFound:
                print("❌ [UserRepository] fetchUser failed - User not found: \(id)")
                throw NetworkError.notFound
            case .undocumented(statusCode: let code, _):
                let error = NetworkError.from(statusCode: code)
                print("❌ [UserRepository] fetchUser failed - Status: \(code), Error: \(error)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [UserRepository] fetchUser failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [UserRepository] fetchUser failed - Unexpected error: \(error)")
            throw error
        }
    }

    func fetchUsers() async throws -> [User] {
        let input = Operations.get_sol_users.Input()

        do {
            let response = try await client.get_sol_users(input)

            switch response {
            case .ok(let okResponse):
                let users = try okResponse.body.json
                return users.map { $0.toDomain() }
            case .forbidden:
                print("❌ [UserRepository] fetchUsers failed - Forbidden")
                throw NetworkError.unauthorized
            case .undocumented(statusCode: let code, _):
                let error = NetworkError.from(statusCode: code)
                print("❌ [UserRepository] fetchUsers failed - Status: \(code), Error: \(error)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [UserRepository] fetchUsers failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [UserRepository] fetchUsers failed - Unexpected error: \(error)")
            throw error
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

        do {
            let response = try await client.post_sol_users(input)

            switch response {
            case .created(let createdResponse):
                let userDTO = try createdResponse.body.json
                return userDTO.toDomain()
            case .forbidden:
                print("❌ [UserRepository] createUser failed - Forbidden")
                throw NetworkError.unauthorized
            case .undocumented(statusCode: let code, _):
                let error = NetworkError.from(statusCode: code)
                print("❌ [UserRepository] createUser failed - Status: \(code), Error: \(error)")
                throw error
            }
        } catch let error as NetworkError {
            print("❌ [UserRepository] createUser failed - NetworkError: \(error)")
            throw error
        } catch {
            print("❌ [UserRepository] createUser failed - Unexpected error: \(error)")
            throw error
        }
    }
}

// Note: MockUserRepository is defined in Features/Authentication/Data/Repositories/MockUserRepository.swift
