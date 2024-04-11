//
//  AddEditCourseViewЬщвуд.swift
//  MarketBest
//
//  Created by Macbook Pro on 11.04.2024.
//

import Foundation

class AddEditCourseViewModel: ObservableObject {
    
    @Published var course: CourseModel? = nil
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var price: Double = 0
    @Published var materialsText: String = ""
    @Published var materialsUrl: String = ""
    @Published var status: CourseStatus = .initial
    
    private let createCourseUseCase: CreateCourseUseCase
    private let editCourseUseCase: EditCourseUseCase
    private let userId: UUID
    
    enum CourseStatus {
        case initial
        case loading
        case created
        case createdDraft
        case edited
        case error(message: String)
    }
    
    init(
        createCourseUseCase: CreateCourseUseCase,
        editCourseUseCase: EditCourseUseCase,
        userId: UUID
    ) {
        self.createCourseUseCase = createCourseUseCase
        self.editCourseUseCase = editCourseUseCase
        self.userId = userId
    }
    
    func createCourse() async {
        do {
            DispatchQueue.main.async {
                self.status = .loading
            }
            let course = CourseModel(
                id: UUID(),
                userId: userId,
                name: name,
                description: description,
                price: price,
                materialsText: materialsText,
                materialsUrl: materialsUrl,
                status: .moderation,
                createdAt: Date()
            )
            try await createCourseUseCase.execute(course: course)
            DispatchQueue.main.async {
                self.status = .created
            }
        } catch {
            print("Error with creating new course: \(error)")
            DispatchQueue.main.async {
                self.status = .error(message: error.localizedDescription)
            }
        }
    }
    
    func saveToDrafts() async {
        do {
            DispatchQueue.main.async {
                self.status = .loading
            }
            let course = CourseModel(
                id: UUID(),
                userId: userId,
                name: name,
                description: description,
                price: price,
                materialsText: materialsText,
                materialsUrl: materialsUrl,
                status: .uncompleted,
                createdAt: Date()
            )
            try await createCourseUseCase.execute(course: course)
            DispatchQueue.main.async {
                self.status = .createdDraft
            }
        } catch {
            print("Error with creating draft course: \(error)")
            DispatchQueue.main.async {
                self.status = .error(message: error.localizedDescription)
            }
        }
    }
    
    func editCourse(model: CourseModel) async {
        // ❌ check any changes before sending to moderation!!!
        do {
            DispatchQueue.main.async {
                self.status = .loading
            }
            let course = CourseModel(
                id: model.id,
                userId: userId,
                name: name,
                description: description,
                price: price,
                materialsText: materialsText,
                materialsUrl: materialsUrl,
                status: .moderation,
                createdAt: model.createdAt
            )
            try await createCourseUseCase.execute(course: course)
            DispatchQueue.main.async {
                self.status = .edited
            }
        } catch {
            print("Error with creating new course: \(error)")
            DispatchQueue.main.async {
                self.status = .error(message: error.localizedDescription)
            }
        }
    }
    
}
