//
//  DBRepository.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation
import Combine

protocol DBRepository {
    func loadSchemes() throws -> [DBDataTable]
    func loadData<V>(
        from table: String,
        itemsPerPage: Int,
        orderBy columnName: String,
        afterValue: V?
    ) -> [DBDataRow]
}

enum DatabaseError: Error {
    case initializeFailed
}

extension DatabaseError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .initializeFailed:
            return "Database initialization failed."
        }
    }
}
