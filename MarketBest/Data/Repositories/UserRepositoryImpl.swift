//
//  UserRepositoryImpl.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation

class UserRepositoryImpl: UserRepository {

    private let remoteDataSource: RemoteDataSource<UserModel>
    private let localDataSource: LocalDataSource<UserEntity>
    
    init(remoteDataSource: RemoteDataSource<UserModel>, localDataSource: LocalDataSource<UserEntity>) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func createUser(user: UserModel) async throws {
        do {
            let _ = try await remoteDataSource.create(model: user)
            try await localDataSource.create(model: user)
        } catch {
            throw error
        }
    }
    
    func updateUser(user: UserModel) async throws {
        do {
            let _ = try await remoteDataSource.update(model: user)
            try await localDataSource.create(model: user)
        } catch {
            throw error
        }
    }
    
    func fetchCurrentUser() async throws -> UserModel? {
        do {
            let user = try await remoteDataSource.fetchCurrentUser()
            print("fetchCurrentUser: \(user)")
            if let user {
                try await localDataSource.saveOrUpdateUser(model: user)
            }
            return user
        } catch {
            print("failure in fetchCurrentUser: \(error)")
            // On failure, attempt to fetch courses from the local data source
            do {
                let localUser = try await localDataSource.fetchCurrentUser()
                return localUser
            } catch {
                throw error
            }
        }
    }
    
    func updateUserRole(userId: UUID, newRole: UserRole) async throws {
        do {
            try await remoteDataSource.updateUserRole(userId: userId, newRole: newRole)
            if var currentUser = try? await fetchCurrentUser() {
                currentUser.role = newRole
                try await localDataSource.saveOrUpdateUser(model: currentUser)
            }
        } catch {
            throw error
        }
    }
    
}
