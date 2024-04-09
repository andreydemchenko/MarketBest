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
    
    func fetchCurrentUser() async throws -> UserModel? {
        do {
            let user = try await remoteDataSource.fetchCurrentUser()
            if let user {
                try await localDataSource.saveOrUpdateUser(model: user)
            }
            return user
        } catch {
            // On failure, attempt to fetch courses from the local data source
            do {
                let localUser = try await localDataSource.fetchById(id: "")
                return localUser
            } catch {
                throw error
            }
        }
    }
    
    func updateUserRole(userId: String, newRole: UserRole) async throws {
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
    
    func signOut() async throws {
        do {
            try await remoteDataSource.signOut()
            try await localDataSource.removeCurrentUser()
        } catch {
            throw error
        }
    }
}
