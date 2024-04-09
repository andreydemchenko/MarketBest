//
//  DependencyContainer.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import Supabase

class DependencyContainer: ObservableObject {
    let networkManager = NetworkManager()
    let coreDataStack = CoreDataStack()
    
    lazy var supabaseClient = networkManager.supabase

    lazy var coursesRemoteDataSource = RemoteDataSource<CourseModel>(supabaseClient: supabaseClient)
    lazy var usersRemoteDataSource = RemoteDataSource<UserModel>(supabaseClient: supabaseClient)

    lazy var coursesLocalDataSource = LocalDataSource<CourseEntity>(container: coreDataStack.container)
    lazy var usersLocalDataSource = LocalDataSource<UserEntity>(container: coreDataStack.container)

    lazy var courseRepository: CourseRepository = CourseRepositoryImpl(remoteDataSource: coursesRemoteDataSource, localDataSource: coursesLocalDataSource)
    lazy var fetchCoursesUseCase = FetchCoursesUseCase(repository: courseRepository)
    
    lazy var userRepository: UserRepository = UserRepositoryImpl(remoteDataSource: usersRemoteDataSource, localDataSource: usersLocalDataSource)
    lazy var fetchCurrentUserUseCase = FetchCurrentUserUseCase(repository: userRepository)
    lazy var signOutUseCase = SignOutUseCase(repository: userRepository)
    
    lazy var authStateManager = AuthStateManager(currentUserUseCase: fetchCurrentUserUseCase)
}
