//
//  DBDataTable.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation

struct DBDataTable {
    let id: String = UUID().uuidString
    let name: String
    var rows: [DBDataRow]

    var numberOfColumns: Int {
        guard let row = rows.first else { return 0 }
        return row.items.count
    }
}

extension DBDataTable: Identifiable {}
