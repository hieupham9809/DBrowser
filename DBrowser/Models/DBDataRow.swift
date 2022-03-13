//
//  DBDataRow.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation

struct DBDataRow {
    let id: String = UUID().uuidString
    let items: [DBDataItemDisplayable]
    let isHeaderRow: Bool
}

extension DBDataRow: Identifiable {}
