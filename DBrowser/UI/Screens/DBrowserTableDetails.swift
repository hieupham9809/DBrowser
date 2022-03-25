//
//  DBrowserTableDetails.swift
//  DBrowser
//
//  Created by Harley Pham on 14/03/2022.
//

import Foundation
import SwiftUI

public struct DBrowserTableDetails: View {
    @Environment(\.injected) private var injected: DIContainer

    let table: DBDataTable
    let itemsPerPage: Int = 20

    @State private(set) var rows: Loadable<[DBDataRow]>
    @State private(set) var currentPage: Int = 1

    init(table: DBDataTable) {
        self.table = table
        self._rows = .init(initialValue: .notRequested)
    }

    // For debugging only
    init(rows: [DBDataRow]) {
        self.table = DBDataTable(name: "", rows: [])
        self._rows = .init(initialValue: .loaded(rows))
    }

    public init(tableName: String, dbFilePath: String) {
        self.table = DBDataTable(name: tableName, rows: [])
        self._rows = .init(initialValue: .notRequested)
        let dbDataInteractor = try! SQLiteDBDataInteractor(
            sqliteFileRepository: SQLiteFileRepository(path: dbFilePath)
        )
        let interactors = DIContainer.Interactors(dbDataInteractor: dbDataInteractor)
        debugInjected = DIContainer(interactors: interactors)
    }
    var debugInjected: DIContainer!

    public var body: some View {
        content
        // enable for easier debugging
            .onAppear {
                debugInjected.interactors.dbDataInteractor.loadDataTo(
                    $rows,
                    from: table.name,
                    itemsPerPage: itemsPerPage,
                    orderBy: nil
                )
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
}

// MARK: Displaying content

extension DBrowserTableDetails {
    func loadView(_ rows: [DBDataRow]) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("Header Toolbar here: Filter, search")
            }
            ScrollView(.horizontal) {
                List(Array(zip(rows.indices, rows)), id: \.1.id) { (index, row) in
                    HStack(spacing: 0) {
                        ForEach(row.items, id: \.id) { item in
                            Text("\(item.value)")
                                .padding(4)
                                .frame(width: Constants.defaultColumnWidth)
                                .frame(maxHeight: Constants.maximumRowHeight)
                                .foregroundColor(row.isHeaderRow ? Color.white : .black)
                                .overlay(
                                    Rectangle()
                                        .frame(width: Constants.cellSeparatorWidth, height: nil, alignment: .trailing)
                                        .foregroundColor(Color.gray),
                                    alignment: .trailing
                                )
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
                .frame(width: CGFloat(9/*table.numberOfColumns*/) * Constants.defaultColumnWidth)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.tableCornerRadius).stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(Constants.tableCornerRadius)
                .listStyle(PlainListStyle())
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
                }
            }
            PagingControllerView(currentPage: $currentPage, totalPage: 10)
        }
        .padding(10)
    }
}

struct Previews_DBrowserTableDetails_Previews: PreviewProvider {
    static var previews: some View {
        DBrowserTableDetails(rows: [])
    }
}
