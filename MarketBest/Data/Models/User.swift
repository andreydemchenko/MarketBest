//
//  User.swift
//  MarketBest
//
//  Created by Macbook Pro on 09.04.2024.
//

import Foundation
import CoreData

struct UserModel: SupabaseModel, IdentifiableModel {
    static let tableName = "users"
    
    let id: String
    let name: String
    let email: String?
    var role: UserRole = .guest
}

enum UserRole: String, Codable, CaseIterable {
    case guest = "guest"
    case customer = "customer"
    case admin = "admin"
    
    static func withLabel(_ label: String) -> UserRole? {
        return self.allCases.first{ "\($0)" == label }
    }
}


extension UserEntity: CoreDataRepresentable {
    
    typealias Model = UserModel

    func update(with model: UserModel, in context: NSManagedObjectContext) {
        self.id = model.id
        self.name = model.name
        self.email = model.email
        self.role = model.role.rawValue
    }
    
    func toModel() -> UserModel {
        return UserModel(id: id!, name: name!, email: email!, role: UserRole.withLabel(role!)!)
    }
}
