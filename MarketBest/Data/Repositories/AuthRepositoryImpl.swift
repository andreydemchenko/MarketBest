//
//  AuthRepositoryImpl.swift
//  MarketBest
//
//  Created by Macbook Pro on 10.04.2024.
//

import Foundation

class AuthRepositoryImpl: AuthRepository {
    
    private let remoteDataSource: RemoteDataSource<UserModel>
    private let localDataSource: LocalDataSource<UserEntity>
    
    init(remoteDataSource: RemoteDataSource<UserModel>, localDataSource: LocalDataSource<UserEntity>) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func signUp(email: String, password: String) async throws -> String? {
        do {
            return try await remoteDataSource.signUp(email: email, password: password)
        } catch {
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws -> String? {
        do {
            return try await remoteDataSource.signIn(email: email, password: password)
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
