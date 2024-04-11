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

    // remote data sources
    lazy var coursesRemoteDataSource = RemoteDataSource<CourseModel>(supabaseClient: supabaseClient)
    lazy var usersRemoteDataSource = RemoteDataSource<UserModel>(supabaseClient: supabaseClient)

    // local data sources
    lazy var coursesLocalDataSource = LocalDataSource<CourseEntity>(container: coreDataStack.container)
    lazy var usersLocalDataSource = LocalDataSource<UserEntity>(container: coreDataStack.container)
    
    //repositories
    lazy var courseRepository: CourseRepository = CourseRepositoryImpl(remoteDataSource: coursesRemoteDataSource, localDataSource: coursesLocalDataSource)
    lazy var userRepository: UserRepository = UserRepositoryImpl(remoteDataSource: usersRemoteDataSource, localDataSource: usersLocalDataSource)
    lazy var authRepository: AuthRepository = AuthRepositoryImpl(remoteDataSource: usersRemoteDataSource, localDataSource: usersLocalDataSource)

    // course usecases
    lazy var fetchCoursesUseCase = FetchCoursesUseCase(repository: courseRepository)
    lazy var fetchMyCoursesUseCase = FetchMyCoursesUseCase(repository: courseRepository)
    lazy var createCourseUseCase = CreateCourseUseCase(repository: courseRepository)
    lazy var editCourseUseCase = EditCourseUseCase(repository: courseRepository)
    lazy var updateCourseStatusUseCase = UpdateCourseStatusUseCase(repository: courseRepository)
    
    // user usecases
    lazy var createUserUseCase = CreateUserUseCase(repository: userRepository)
    lazy var updateUserUseCase = UpdateUserUseCase(repository: userRepository)
    lazy var fetchCurrentUserUseCase = FetchCurrentUserUseCase(repository: userRepository)
    
    // auth usecases
    lazy var signOutUseCase = SignOutUseCase(repository: authRepository)
    lazy var signInUseCase = SignInUseCase(repository: authRepository)
    lazy var signUpUseCase = SignUpUseCase(repository: authRepository)
    
    lazy var authStateManager = AuthStateManager(currentUserUseCase: fetchCurrentUserUseCase)
}
