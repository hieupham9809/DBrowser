//
//  SQLiteDBDataInteractor.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation
import SwiftUI
import Combine

struct SQLiteDBDataInteractor: DBDataInteractor {
    let sqliteFileRepository: SQLiteFileRepository
    let queue = DispatchQueue(label: "dbrowser.sqlitedbdata.interactor")

    func loadAllTableSchemes(schemes: Binding<Loadable<[DBDataTable]>>) {
        let cancelBag = CancelBag()
        schemes.wrappedValue.setIsLoading(cancelBag: cancelBag)
        Just(Void()).subscribe(on: queue)
            .map { _ in
                return .loaded((try? sqliteFileRepository.loadSchemes()) ?? [])
            }
            .receive(on: DispatchQueue.main)
            .sink {
                schemes.wrappedValue = $0
            }.store(in: cancelBag)
    }

    func loadAllTableSchemes() -> [DBDataTable] {
        (try? sqliteFileRepository.loadSchemes()) ?? []
    }

    func loadDataTo(
        _ rows: Binding<Loadable<[DBDataRow]>>,
        from table: String,
        itemsPerPage: Int,
        order: DBOrder,
        by values: [String: Any]?
    )
    {
        let cancelBag = CancelBag()
        rows.wrappedValue.setIsLoading(cancelBag: cancelBag)
        Just(Void()).subscribe(on: queue)
            .map { _ in
                return .loaded(
                    sqliteFileRepository.loadData(
                        from: table, itemsPerPage: itemsPerPage, order: order, by: values
                    )
                )
            }
            .receive(on: DispatchQueue.main)
            .sink {
                rows.wrappedValue = $0
            }
            .store(in: cancelBag)
    }

    func getPageInfo(from table: String, itemsPerPage: Int, orderBy columns: [String]) -> [[String : Any]] {
        sqliteFileRepository.getPageInfo(from: table, itemsPerPage: itemsPerPage, orderBy: columns)
    }

    func columnForRowId() -> String? {
        SQLiteFileRepository.PrimaryColumns.rowid
    }
}
