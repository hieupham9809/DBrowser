//
//  DBrowserTableDetails.swift
//  DBrowser
//
//  Created by Harley Pham on 14/03/2022.
//

import Foundation
import SwiftUI

struct DBrowserTableDetails: View {
    @Environment(\.injected) private var injected: DIContainer

    let table: DBDataTable
    let itemsPerPage: Int = 20

    @State private(set) var rows: Loadable<[DBDataRow]>
    @State private(set) var currentPage: Int? = 1
    @State private(set) var totalPage: Int = 0

    @State private var pageMapping: [[String: Any]] = [["rowid": 0]]
    @State private var columnToSort: SortingValue?

    // table doesn't need rowid will be handled separately (must have `columnToSort`)
    private var tableNeedsRowId: Bool = true
    
    init(table: DBDataTable) {
        self.table = table
        self._rows = .init(initialValue: .notRequested)
    }

    // For debugging only
    init(rows: [DBDataRow]) {
        self.table = DBDataTable(name: "", rows: [])
        self._rows = .init(initialValue: .loaded(rows))
    }

    init(tableName: String, dbFilePath: String) {
        self.table = DBDataTable(name: tableName, rows: [])
        self._rows = .init(initialValue: .notRequested)
        let dbDataInteractor = try! SQLiteDBDataInteractor(
            sqliteFileRepository: SQLiteFileRepository(path: dbFilePath)
        )
        let interactors = DIContainer.Interactors(dbDataInteractor: dbDataInteractor)
        debugInjected = DIContainer(interactors: interactors)
    }
    
    var debugInjected: DIContainer!

    var body: some View {
        Group {
            switch rows {
            case .isLoading(_, _): loadingView().padding(0)
            case let .loaded(rows): loadView(rows)
            default: Text("unsupported")
            }
        }
        // enable for easier debugging
            .onAppear {
                loadPageInfos()
            }
            .onChange(of: currentPage) { currentPage in
                guard let currentPage = currentPage else {
                    return
                }

                loadPageData(by: currentPage)
            }
            .onChange(of: columnToSort) { column in
                guard let _ = column else { return }
                loadPageInfos()
            }

    }

    private var content: AnyView {
        switch rows {
        case .isLoading(_, _): return AnyView(loadingView().padding(0))
        case let .loaded(rows): return AnyView(loadView(rows))
        default: return AnyView(Text("unsupported"))
        }
    }
}

// MARK: Loading content

extension DBrowserTableDetails {
    func loadingView() -> some View {
        ActivityIndicatorView()
    }

    private func getConstraintValues(by page: Int) -> [String: Any]? {
        guard page - 1 >= 0, page - 1 < pageMapping.count else { return nil }
        return pageMapping[page - 1]
    }

    private func loadPageInfos() {
        let interactor = injected.interactors.dbDataInteractor
        let orderByColumns = [columnToSort?.columnValue, tableNeedsRowId ? interactor.columnForRowId() : nil]
            .compactMap { $0 }

        pageMapping = interactor.getPageInfo(
            from: table.name, itemsPerPage: itemsPerPage, orderBy: orderByColumns
        )

        totalPage = pageMapping.count

        if let currentPage = currentPage {
            loadPageData(by: currentPage)
        }
    }

    private func loadPageData(by page: Int) {
        injected.interactors.dbDataInteractor.loadDataTo(
            $rows,
            from: table.name,
            itemsPerPage: itemsPerPage,
            order: columnToSort?.order ?? .asc,
            by: getConstraintValues(by: page)
        )
    }
}

// MARK: Displaying content

extension DBrowserTableDetails {
    func loadView(_ rows: [DBDataRow]) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("Header Toolbar here: Filter, search")
                    .frame(width: nil, height: 40, alignment: .center)
            }
            ScrollView(.horizontal) {
                List(Array(zip(rows.indices, rows)), id: \.1.id) { (index, row) in
                    HStack(spacing: 0) {
                        ForEach(row.items, id: \.id) { item in
                            cellBuilder(from: item, isHeaderRow: row.isHeaderRow)
                                .frame(width: Constants.defaultColumnWidth)
                                .frame(maxHeight: Constants.maximumRowHeight)
                                .overlayCellWithBorder()
                        }
                    }
                    .overlay(
                        Rectangle()
                            .frame(width: nil, height: Constants.cellSeparatorWidth, alignment: .bottom)
                            .foregroundColor(Color.gray),
                        alignment: .bottom
                    )
                    .background(
                        row.isHeaderRow ? Color.blue : ((index % 2 == 0) ? Color(hex: "#C1E3FF") : .white)
                    )
                    .listRowInsets(EdgeInsets())
                    .hideRowSeparator()
                }
                .environment(\.defaultMinListRowHeight, 10)
                .padding(0)
                .frame(width: CGFloat(table.numberOfColumns) * Constants.defaultColumnWidth)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.tableCornerRadius).stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(Constants.tableCornerRadius)
                .listStyle(PlainListStyle())
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
                }
            }
            PagingControllerView(currentPage: $currentPage, totalPage: $totalPage)
                .frame(width: nil, height: 81, alignment: .center)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    }

    private func cellContentBuilder(from item: DBDataItemDisplayable, isHeaderRow: Bool) -> some View {
        Text("\(item.value)")
            .foregroundColor(isHeaderRow ? Color.white : .black)
            .padding(4)
    }

    private func cellBuilder(from item: DBDataItemDisplayable, isHeaderRow: Bool) -> some View {
        Group {
            if isHeaderRow {
                HeaderItemView(
                    content: { cellContentBuilder(from: item, isHeaderRow: isHeaderRow) },
                    itemValue: item.value,
                    currentOrderColumn: $columnToSort
                )
            }
            else {
                cellContentBuilder(from: item, isHeaderRow: isHeaderRow)
            }
        }
    }
}

struct Previews_DBrowserTableDetails_Previews: PreviewProvider {
    static var previews: some View {
        DBrowserTableDetails(rows: [])
    }
}
