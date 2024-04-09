//
//  Course.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import CoreData

struct CourseModel: SupabaseModel, IdentifiableModel {

    
    static let tableName = "courses"
    
    let id: String
    let title: String
    let description: String
    let price: Double
    
}

extension CourseEntity: CoreDataRepresentable {
    typealias Model = CourseModel

    func update(with model: CourseModel, in context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.title
        self.course_description = model.description
        self.price = model.price
    }
    
    func toModel() -> CourseModel {
        return CourseModel(id: id!, title: name!, description: course_description!, price: price)
    }
}
