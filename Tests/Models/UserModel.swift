//
//  UserModel.swift
//  CodableFiles
//
//  Created by Egzon Pllana on 2.4.23.
//

import Foundation

struct User: Codable, Equatable {
    let firstName: String
    let lastName: String
}

extension User {
    static func fake() -> Self {
        .init(firstName: "First name", lastName: "LastName")
    }
}
