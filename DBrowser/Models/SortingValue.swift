//
//  SortingValue.swift
//  DBrowser
//
//  Created by Harley Pham on 19/04/2022.
//

import Foundation

struct SortingValue: Equatable {
    var order: DBOrder
    let columnValue: String

    mutating func toggle() {
        if order == .asc {
            order = .desc
        }
        else {
            order = .asc
        }
    }
}
