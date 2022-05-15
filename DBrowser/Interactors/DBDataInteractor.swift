//
//  DBDataInteractor.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation
import SwiftUI

protocol DBDataInteractor {
    func loadAllTableSchemes(schemes: Binding<Loadable<[DBDataTable]>>)
    func loadAllTableSchemes() -> [DBDataTable]
    func loadDataTo(
        _ rows: Binding<Loadable<[DBDataRow]>>,
        from table: String,
        itemsPerPage: Int,
        order: DBOrder,
        by values: [String: Any]?
    )
    func getPageInfo(from table: String, itemsPerPage: Int, orderBy columns: [String]) -> [[String : Any]]
    func columnForRowId() -> String?
}

struct InitialDBDataInteractor: DBDataInteractor {
    func loadAllTableSchemes(schemes: Binding<Loadable<[DBDataTable]>>) { }
    func loadAllTableSchemes() -> [DBDataTable] { [] }
    func loadDataTo(
        _ rows: Binding<Loadable<[DBDataRow]>>,
        from table: String,
        itemsPerPage: Int,
        order: DBOrder,
        by values: [String: Any]?
    ) { }
    func getPageInfo(from table: String, itemsPerPage: Int, orderBy columns: [String]) -> [[String : Any]] { [] }
    func columnForRowId() -> String? { nil }
}
