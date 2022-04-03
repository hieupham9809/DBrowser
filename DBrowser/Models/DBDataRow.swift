//
//  DBDataRow.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation

struct DBDataRow {
    let items: [DBDataItemDisplayable]
    let isHeaderRow: Bool
    let rowId: DBDataItemDisplayable?
}

extension DBDataRow: Identifiable {
    var id: String {
        rowId?.value ?? "unsupported"
    }
}
