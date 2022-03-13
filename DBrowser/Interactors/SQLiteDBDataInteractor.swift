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

    func loadData<V>(from table: String, itemsPerPage: Int, orderBy: String, afterValue: V?) {
        _ = sqliteFileRepository.loadData(
            from: table, itemsPerPage: itemsPerPage, orderBy: orderBy, afterValue: afterValue
        )
    }
}