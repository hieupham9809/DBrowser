//
//  SQLiteFileRepository.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation
import Combine
import SQLite3

enum DBOrder: String, CustomStringConvertible {
    case asc = "ASC"
    case desc = "DESC"

    var description: String {
        rawValue
    }
}

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

    private func tableColumnQueryString(_ tableName: String) -> String {
        "PRAGMA table_info(\(tableName))"
    }
}

// MARK: Scheme table
extension SQLiteFileRepository {
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
                currentTable?.rows.append(
                    DBDataRow(
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
                        isHeaderRow: true, rowId: nil
                    )
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
            isHeaderRow: false,
            rowId: DBDataSchemeItem(value: UUID().uuidString)
        )
    }
}

// MARK: Table data
extension SQLiteFileRepository {
    // MARK: Retrieve table data
    func loadData(
        from table: String,
        itemsPerPage: Int,
        order: DBOrder,
        by values: [String: Any]? = nil
    ) -> [DBDataRow] {
        guard let headerRow = getTableRowForHeader(table) else { return [] }
        let queryString = loadDataQueryString(
            from: table, numberOfItems: itemsPerPage,
            order: order, by: values ?? [PrimaryColumns.rowid: 1]
        )
        var queryStatement: OpaquePointer?

        guard sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK else { return [] }

        let columnCount = sqlite3_column_count(queryStatement)
        var result: [DBDataRow] = [headerRow]

        while sqlite3_step(queryStatement) == SQLITE_ROW {
            var items: [DBDataItemDisplayable] = []
            let rowId = getDBItem(from: queryStatement, columnIndex: 0)
            for index in 1..<columnCount { // TODO: `WITHOUT ROWID` table should start at 0
                items.append(getDBItem(from: queryStatement, columnIndex: index))
            }
            guard items.isEmpty == false else { continue }
            result.append(DBDataRow(items: items, isHeaderRow: false, rowId: rowId))
        }
        print("DATA: \(result)")
        return result
    }

    private func loadDataQueryString(
        from table: String,
        numberOfItems: Int,
        order: DBOrder,
        by values: [String: Any]
    ) -> String {
        let keys = values.keys
        return "SELECT \(PrimaryColumns.rowid), * FROM \(table)"
        + """
         WHERE (\(keys.joined(separator: ", "))) >=
        (\(keys.compactMap { key in values[key].map { "\(convert($0))" } }.joined(separator: ", ")))
        """
        + " ORDER BY \(values.keys.map { "\($0) \(order)" }.joined(separator: ", "))"
        + " LIMIT \(numberOfItems);"
    }

    private func convert(_ value: Any) -> Any {
        if let text = value as? String { return "'\(text)'"}
        return value
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
        return DBDataRow(items: columnItems, isHeaderRow: true, rowId: nil)
    }
}

// MARK: table paging info
extension SQLiteFileRepository {

    func getPageInfo(from table: String, itemsPerPage: Int, orderBy columns: [String]) -> [[String: Any]] {
        let totalRowCount = getTotalRowCount(from: table)
        guard totalRowCount > 0 else { return [] }
        let numberOfPages = Int((CGFloat(totalRowCount) / CGFloat(itemsPerPage)).rounded(.up))
        var offsets: [Int] = []

        for page in 0..<numberOfPages {
            offsets.append(page * itemsPerPage + 1)
        }

        let queryString = getRowQueryString(from: table, totalRowCount: totalRowCount, orderBy: columns, by: offsets)
        print("QUERY: \(queryString)")
        var queryStatement: OpaquePointer?

        guard sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK else { return [] }
        var result: [[String: Any]] = []

        while sqlite3_step(queryStatement) == SQLITE_ROW {
            var rowPageInfo: [String: Any] = [:]
            columns.enumerated().forEach { index, column in
                rowPageInfo[column] = getDBItem(from: queryStatement, columnIndex: Int32(index)).actualValue
            }
            result.append(rowPageInfo)
        }
        print("paging info: \(result)")
        return result
    }

    private func getRowQueryString(
        from table: String, totalRowCount: Int, orderBy columns: [String], by offsets: [Int]
    ) -> String {
        let order: DBOrder = .asc
        return """
            SELECT \(columns.map { "t.\($0)" }.joined(separator: ", "))
            FROM \(table) t
            WHERE (
                    SELECT COUNT(*) FROM \(table)
                    WHERE (\(columns.joined(separator: ", "))) > (\(columns.map { "t.\($0)" }.joined(separator: ", ")))
            ) IN (\(offsets.map { "\(totalRowCount - $0)" }.joined(separator: ", ")))
            ORDER BY \(columns.map { "t.\($0) \(order)" }.joined(separator: ", "))
            """
    }

    private func getTotalRowCount(from table: String) -> Int {
        let queryString = countDataQueryString(from: table)
        var queryStatement: OpaquePointer?
        guard sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK,
              sqlite3_step(queryStatement) == SQLITE_ROW
        else { return 0 }
        return Int(sqlite3_column_int(queryStatement, 0))
    }

    private func countDataQueryString(from table: String) -> String {
        "SELECT count(*) from \(table)"
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

extension SQLiteFileRepository {
    enum PrimaryColumns {
        static let rowid = "rowid"
    }
}
