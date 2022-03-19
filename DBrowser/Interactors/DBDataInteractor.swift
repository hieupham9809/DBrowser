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
    func loadDataTo<V>(
        _ rows: Binding<Loadable<[DBDataRow]>>,
        from table: String,
        itemsPerPage: Int,
        orderBy: String,
        afterValue: V?
    )
}

struct InitialDBDataInteractor: DBDataInteractor {
    func loadAllTableSchemes(schemes: Binding<Loadable<[DBDataTable]>>) { }
    func loadDataTo<V>(
        _ rows: Binding<Loadable<[DBDataRow]>>,
        from table: String,
        itemsPerPage: Int,
        orderBy: String,
        afterValue: V?
    ) { }
}
