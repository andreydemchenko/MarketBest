//
//  UploadMediaItemUseCase.swift
//  MarketBest
//
//  Created by Macbook Pro on 15.04.2024.
//

import Foundation

class UploadMediaItemUseCase {
    
    private let repository: CourseMediaRepository
    
    init(repository: CourseMediaRepository) {
        self.repository = repository
    }
    
    func execute(fileData: Data, fileName: String, contentType: String) async throws -> URL? {
        return try await repository.uploadMediaItem(fileData: fileData, fileName: fileName, contentType: contentType)
    }
    
}
