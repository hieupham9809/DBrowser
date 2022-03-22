//
//  SQLiteFileRepository.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation
import Combine
import SQLite3

struct SQLiteFileRepository: DBRepository {
    private var db: OpaquePointer?

    public init(path: String) throws {
        guard sqlite3_open(path, &db) == SQLITE_OK, let _ = db else {
            throw DatabaseError.initializeFailed
        }
    }

    // MARK: Retrieve DB scheme

    private let schemeColumnNameQueryMapper: [SchemeColumnName: String] = [
        .tableName: "m.name AS table_name",
        .columnId: "p.cid AS col_id",
        .columnName: "p.name AS col_name",
        .columnType: "p.type AS col_type",
        .columnIsPK: "p.pk AS col_is_pk",
        .columnDefaultValue: "p.dflt_value AS col_default_val",
        .columnIsNotNull: "p.[notnull] AS col_is_not_null"
    ]

    func loadSchemes() throws -> [DBDataTable] {
        let queryString = loadSchemeQueryString()
        var queryStatement: OpaquePointer?

        guard sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK else { return [] }

        var result: [DBDataTable] = []
        var currentTableName: String = ""
        var currentTable: DBDataTable?
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            let tableName = sqlite3_column_text(queryStatement, index(by: .tableName)).flatMap { String(cString: $0) }
            guard let tableName = tableName else { continue }
            // create new table model if `tableName` is different from current
            if currentTableName != tableName {
                if let currentTable = currentTable {
                    result.append(currentTable)
                }
                currentTableName = tableName
                currentTable = DBDataTable(name: tableName, rows: [])

                // append column header
                currentTable?.rows.append(DBDataRow(
                    items: [
                        .columnId,
                        .columnName,
                        .columnType,
                        .columnIsPK,
                        .columnDefaultValue,
                        .columnIsNotNull
                    ].map { (column: SchemeColumnName) -> DBDataSchemeItem in
                        DBDataSchemeItem(value: column.columnDesc)
                    },
                    isHeaderRow: true)
                )
                currentTable?.rows.append(extractSchemeRowModel(from: queryStatement))
            }
            else { // else continue to append to current table
                currentTable?.rows.append(extractSchemeRowModel(from: queryStatement))
            }
        }

        if let currentTable = currentTable,
            result.firstIndex(where: { $0.name == currentTable.name }) == nil {
            result.append(currentTable)
        }

        print(result)
        sqlite3_finalize(queryStatement)
        return result
    }

    private func loadSchemeQueryString() -> String {
        return """
            SELECT
            \(SchemeColumnName.allCases.compactMap { schemeColumnNameQueryMapper[$0] }.joined(separator: ", "))
            FROM sqlite_master m
            LEFT OUTER JOIN pragma_table_info((m.name)) p
              ON m.name <> p.name
            WHERE m.type = 'table'
            ORDER BY table_name, col_id
            """
    }

    private func extractSchemeRowModel(from row: OpaquePointer?) -> DBDataRow {
        return DBDataRow(
            items: [
                sqlite3_column_text(row, index(by: .columnId)),
                sqlite3_column_text(row, index(by: .columnName)),
                sqlite3_column_text(row, index(by: .columnType)),
                sqlite3_column_text(row, index(by: .columnIsPK)),
                sqlite3_column_text(row, index(by: .columnDefaultValue)),
                sqlite3_column_text(row, index(by: .columnIsNotNull)),
            ].map { item in
                DBDataSchemeItem(value: item.flatMap { String(cString: $0) } ?? "unknown")
            },
            isHeaderRow: false
        )
    }

    // MARK: Retrieve table data

    func loadData(
        from table: String,
        itemsPerPage: Int,
        orderBy: (columnName: String, afterValue: Any)? = (columnName: "rowid", afterValue: 0)
    ) -> [DBDataRow] {
        guard let headerRow = getTableRowForHeader(table) else { return [] }
        let queryString = queryString(
            from: table, numberOfItems: itemsPerPage,
            orderBy: orderBy?.columnName ?? "rowid", afterValue: orderBy?.afterValue ?? 0
        )
        var queryStatement: OpaquePointer?

        guard sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK else { return [] }

        let columnCount = sqlite3_column_count(queryStatement)
        var result: [DBDataRow] = [headerRow]

        while sqlite3_step(queryStatement) == SQLITE_ROW {
            var items: [DBDataItemDisplayable] = []
            for index in 0..<columnCount {
                items.append(getDBItem(from: queryStatement, columnIndex: index))
            }
            guard items.isEmpty == false else { continue }
            result.append(DBDataRow(items: items, isHeaderRow: false))
        }
        print("DATA: \(result)")
        return result
    }

    private func queryString(
        from table: String,
        numberOfItems: Int,
        orderBy columnName: String,
        afterValue: Any
    ) -> String {
        "SELECT * FROM \(table)"
        + " WHERE \(columnName) > \(afterValue)"
        + " ORDER BY \(columnName)"
        + " LIMIT \(numberOfItems);"
    }

    func getDBItem(from statement: OpaquePointer?, columnIndex: Int32) -> DBDataItemDisplayable {
        switch sqlite3_column_type(statement, columnIndex) {
        case SQLITE_FLOAT:
            return DBDataItem(value: sqlite3_column_double(statement, columnIndex))
        case SQLITE_INTEGER:
            return DBDataItem(value: sqlite3_column_int(statement, columnIndex))
        case SQLITE_NULL:
            return DBDataNilItem()
        case SQLITE_TEXT:
            let text = sqlite3_column_text(statement, columnIndex)
            return text.map { DBDataItem(value: String(cString: $0)) } ?? DBDataNilItem()
        case let type:
            fatalError("unsupported column type: \(type)")
        }
    }

    private func getTableRowForHeader(_ tableName: String) -> DBDataRow? {
        let queryString = tableColumnQueryString(tableName)
        let tableColumnNameRowIndex: Int32 = 1

        var queryStatement: OpaquePointer?
        guard sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK else { return nil }
        var columnItems: [DBDataItemDisplayable] = []

        while sqlite3_step(queryStatement) == SQLITE_ROW {
            columnItems.append(
                DBDataSchemeItem(
                    value: String(cString: sqlite3_column_text(queryStatement, tableColumnNameRowIndex))
                )
            )
        }
        guard columnItems.isEmpty == false else { return nil }
        return DBDataRow(items: columnItems, isHeaderRow: true)
    }

    private func tableColumnQueryString(_ tableName: String) -> String {
        "PRAGMA table_info(\(tableName))"
    }
}

extension SQLiteFileRepository {
    enum SchemeColumnName: Int, CaseIterable {
        case tableName = 0, columnId, columnName, columnType
        case columnIsPK, columnDefaultValue, columnIsNotNull

        var columnDesc: String {
            switch self {
            case .tableName:
                return "Table Name"
            case .columnId:
                return "Column ID"
            case .columnName:
                return "Column Name"
            case .columnType:
                return "Column Type"
            case .columnIsPK:
                return "Primary Key"
            case .columnDefaultValue:
                return "Default Value"
            case .columnIsNotNull:
                return "Non Null"
            }
        }
    }

    private func index(by column: SchemeColumnName) -> Int32 {
        return Int32(column.rawValue)
    }
}
