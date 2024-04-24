//
//  CourseMediaUseCases.swift
//  MarketBest
//
//  Created by Macbook Pro on 16.04.2024.
//

import Foundation

class CourseMediaUseCases {
    
    let uploadMediaItemUseCase: UploadMediaItemUseCase
    let createMediaItemUseCase: CreateMediaItemUseCase
    let deleteMediaItemUseCase: DeleteMediaItemUseCase
    let fetchCourseMediaUseCase: FetchCourseMediaUseCase
    let fetchAllMediaUseCase: FetchAllMediaUseCase
    let updateMediaItemUseCase: UpdateMediaItemUseCase
    
    init(
        uploadMediaItemUseCase: UploadMediaItemUseCase,
        createMediaItemUseCase: CreateMediaItemUseCase,
        deleteMediaItemUseCase: DeleteMediaItemUseCase,
        fetchCourseMediaUseCase: FetchCourseMediaUseCase,
        fetchAllMediaUseCase: FetchAllMediaUseCase,
        updateMediaItemUseCase: UpdateMediaItemUseCase
    ) {
        self.uploadMediaItemUseCase = uploadMediaItemUseCase
        self.createMediaItemUseCase = createMediaItemUseCase
        self.deleteMediaItemUseCase = deleteMediaItemUseCase
        self.fetchCourseMediaUseCase = fetchCourseMediaUseCase
        self.fetchAllMediaUseCase = fetchAllMediaUseCase
        self.updateMediaItemUseCase = updateMediaItemUseCase
    }
}
