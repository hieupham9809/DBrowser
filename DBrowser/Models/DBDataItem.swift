//
//  DBDataItem.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation

protocol DBDataItemDisplayable {
    var value: String { get }
}

extension DBDataItemDisplayable {
    var id: String { UUID().uuidString }
}

struct DBDataSchemeItem: DBDataItemDisplayable {
    private let _value: String
    var value: String { _value }

    init(value: String) {
        _value = value
    }
}

struct DBDataItem<T: CustomStringConvertible>: DBDataItemDisplayable {
    private let _value: T?
    var value: String {
        _value?.description ?? "nil"
    }

    init(value: T?) {
        _value = value
    }
}

struct DBDataNilItem: DBDataItemDisplayable {
    let value: String = "nil"
}
