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
    func loadDataTo(
        _ rows: Binding<Loadable<[DBDataRow]>>,
        from table: String,
        itemsPerPage: Int,
        orderBy: (columnName: String, afterValue: Any)?
    )
}

struct InitialDBDataInteractor: DBDataInteractor {
    func loadAllTableSchemes(schemes: Binding<Loadable<[DBDataTable]>>) { }
    func loadDataTo(
        _ rows: Binding<Loadable<[DBDataRow]>>,
        from table: String,
        itemsPerPage: Int,
        orderBy: (columnName: String, afterValue: Any)?
    ) { }
}
