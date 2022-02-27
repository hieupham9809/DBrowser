//
//  SQLiteDBDataInteractor.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation
import SwiftUI

struct SQLiteDBDataInteractor: DBDataInteractor {
    let sqliteFileRepository: SQLiteFileRepository

    func loadAllTableSchemes(schemes: Binding<[DBDataTable]>) {
        schemes.wrappedValue = (try? sqliteFileRepository.loadSchemes()) ?? []
    }
}
