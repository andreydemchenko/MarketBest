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
    lazy var storageClient = networkManager.storageClient()

    // remote data sources
    lazy var coursesRemoteDataSource = RemoteDataSource<CourseModel>(supabaseClient: supabaseClient, storageClient: storageClient)
    lazy var usersRemoteDataSource = RemoteDataSource<UserModel>(supabaseClient: supabaseClient, storageClient: storageClient)
    lazy var categoriesRemoteDataSource = RemoteDataSource<CategoryModel>(supabaseClient: supabaseClient, storageClient: storageClient)
    lazy var courseMediaRemoteDataSource = RemoteDataSource<CourseMediaItem>(supabaseClient: supabaseClient, storageClient: storageClient)
    lazy var favouritesRemoteDataSource = RemoteDataSource<FavouriteModel>(supabaseClient: supabaseClient, storageClient: storageClient)

    // local data sources
    lazy var coursesLocalDataSource = LocalDataSource<CourseEntity>(container: coreDataStack.container)
    lazy var usersLocalDataSource = LocalDataSource<UserEntity>(container: coreDataStack.container)
    lazy var categoriesLocalDataSource = LocalDataSource<CategoryEntity>(container: coreDataStack.container)
    
    //repositories
    lazy var courseRepository: CourseRepository = CourseRepositoryImpl(remoteDataSource: coursesRemoteDataSource, localDataSource: coursesLocalDataSource)
    lazy var userRepository: UserRepository = UserRepositoryImpl(remoteDataSource: usersRemoteDataSource, localDataSource: usersLocalDataSource)
    lazy var authRepository: AuthRepository = AuthRepositoryImpl(remoteDataSource: usersRemoteDataSource, localDataSource: usersLocalDataSource)
    lazy var categoriesRepository: CategoryRepository = CategoryRepositoryImpl(remoteDataSource: categoriesRemoteDataSource, localDataSource: categoriesLocalDataSource)
    lazy var courseMediaRepository: CourseMediaRepository = CourseMediaRepositoryImpl(remoteDataSource: courseMediaRemoteDataSource)
    lazy var favouritesRepository: FavouritesRepository = FavouritesRepositoryImpl(remoteDataSource: favouritesRemoteDataSource)

    // course usecases
    lazy var fetchCoursesUseCase = FetchCoursesUseCase(repository: courseRepository)
    lazy var fetchMyCoursesUseCase = FetchMyCoursesUseCase(repository: courseRepository)
    lazy var createCourseUseCase = CreateCourseUseCase(repository: courseRepository)
    lazy var editCourseUseCase = EditCourseUseCase(repository: courseRepository)
    lazy var updateCourseStatusUseCase = UpdateCourseStatusUseCase(repository: courseRepository)
    lazy var fetchCoursesByStatusUseCase = FetchCoursesByStatusUseCase(repository: courseRepository)
    lazy var deleteCourseUseCase = DeleteCourseUseCase(repository: courseRepository)
    
    // favourites usecases
    lazy var addToFavouritesUseCase = AddToFavouritesUseCase(repository: favouritesRepository)
    lazy var removeFromFavouritesUseCase = RemoveFromFavouritesUseCase(repository: favouritesRepository)
    lazy var fetchFavouritesUseCase = FetchFavouritesUseCase(repository: favouritesRepository)
    
    // course media usecases
    lazy var createMediaItemUseCase = CreateMediaItemUseCase(repository: courseMediaRepository)
    lazy var uploadMediaItemUseCase = UploadMediaItemUseCase(repository: courseMediaRepository)
    lazy var deleteMediaItemUseCase = DeleteMediaItemUseCase(repository: courseMediaRepository)
    lazy var fetchCourseMediaUseCase = FetchCourseMediaUseCase(repository: courseMediaRepository)
    lazy var fetchMyMediaUseCase = FetchMyMediaUseCase(repository: courseMediaRepository)
    lazy var fetchAllMediaUseCase = FetchAllMediaUseCase(repository: courseMediaRepository)
    lazy var updateMediaItemUseCase = UpdateMediaItemUseCase(repository: courseMediaRepository)
    lazy var fetchVideoDetailsUseCase = FetchYouTubeVideoDetailsUseCase(repository: courseMediaRepository)
    lazy var courseMediaUseCases = CourseMediaUseCases(
        uploadMediaItemUseCase: uploadMediaItemUseCase,
        createMediaItemUseCase: createMediaItemUseCase,
        deleteMediaItemUseCase: deleteMediaItemUseCase,
        fetchCourseMediaUseCase: fetchCourseMediaUseCase,
        fetchAllMediaUseCase: fetchAllMediaUseCase,
        updateMediaItemUseCase: updateMediaItemUseCase
    )
    
    // user usecases
    lazy var createUserUseCase = CreateUserUseCase(repository: userRepository)
    lazy var updateUserUseCase = UpdateUserUseCase(repository: userRepository)
    lazy var fetchCurrentUserUseCase = FetchCurrentUserUseCase(repository: userRepository)
    
    // auth usecases
    lazy var signOutUseCase = SignOutUseCase(repository: authRepository)
    lazy var signInUseCase = SignInUseCase(repository: authRepository)
    lazy var signUpUseCase = SignUpUseCase(repository: authRepository)
    
    // categories usecases
    lazy var fetchCategoriesUseCase = FetchCategoriesUseCase(repository: categoriesRepository)
    lazy var createCategoryUseCase = CreateCategoryUseCase(repository: categoriesRepository)
    lazy var editCategoryUseCase = EditCategoryUseCase(repository: categoriesRepository)
    
    // managers
    lazy var authStateManager = AuthStateManager(currentUserUseCase: fetchCurrentUserUseCase)
    lazy var favoritesManager = FavoritesManager(
        addToFavouritesUseCase: addToFavouritesUseCase,
        removeFromFavouritesUseCase: removeFromFavouritesUseCase,
        fetchFavouritesUseCase: fetchFavouritesUseCase,
        authStateManager: authStateManager
    )
}
