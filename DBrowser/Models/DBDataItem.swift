//
//  DBDataItem.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation

protocol DBDataItemDisplayable {
    var value: String { get }
    var actualValue: Any { get }
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

    var actualValue: Any {
        _value
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

    var actualValue: Any {
        _value ?? "nil"
    }
}

struct DBDataNilItem: DBDataItemDisplayable {
    let value: String = "nil"

    var actualValue: Any {
        value
    }
}
