//
//  DBrowserMain.swift
//  
//
//  Created by Harley Pham on 13/02/2022.
//

import SwiftUI
import Combine

public struct DBrowserMain: View {
    private let container: DIContainer

    @State private(set) var schemeTables: Loadable<[DBDataTable]>

    init(container: DIContainer, schemeTables: [DBDataTable]) {
        self.container = container
        self._schemeTables = .init(initialValue: .loaded(schemeTables))
    }

    public init(filePath: String) throws {
        let dbDataInteractor = try SQLiteDBDataInteractor(
            sqliteFileRepository: SQLiteFileRepository(path: filePath)
        )
        let interactors = DIContainer.Interactors(dbDataInteractor: dbDataInteractor)
        self.container = DIContainer(interactors: interactors)
        self._schemeTables = .init(initialValue: .notRequested)
    }

    public var body: some View {
        self.content
            .inject(container)
            .onAppear {
                container.interactors.dbDataInteractor.loadAllTableSchemes(schemes: $schemeTables)
            }
            
    }

    // WARNING: using AnyView is not good for SwiftUI's performance
    private var content: AnyView {
        switch schemeTables {
        case .isLoading(_, _): return AnyView(loadingView().padding(0))
        case let .loaded(schemeTables): return AnyView(loadView(schemeTables))
        default: return AnyView(Text("unsupported"))
        }
    }
}

// MARK: Loading content

extension DBrowserMain {
    func loadingView() -> some View {
        ActivityIndicatorView()
    }
}

// MARK: Displaying content

extension DBrowserMain {
    func loadView(_ schemeTables: [DBDataTable]) -> some View {
        List(schemeTables, id: \.id) { table in
            ScrollView(.horizontal) {
                List(Array(zip(table.rows.indices, table.rows)), id: \.1.id) { index, row in
                    HStack(spacing: 0) {
                        ForEach(row.items, id: \.id) { item in
                            Text("\(item.value)")
                                .padding(4)
                                .frame(width: Constant.defaultColumnWidth)
                                .frame(maxHeight: .infinity)
                                .foregroundColor(row.isHeaderRow ? Color.white : .black)
                                .overlay(
                                    Rectangle()
                                        .frame(width: Constant.cellSeparatorWidth, height: nil, alignment: .trailing)
                                        .foregroundColor(Color.gray),
                                    alignment: .trailing
                                )
                        }
                    }
                    .fixedSize()
                    .overlay(
                        Rectangle()
                            .frame(width: nil, height: Constant.cellSeparatorWidth, alignment: .bottom)
                            .foregroundColor(Color.gray),
                        alignment: .bottom
                    )
                    .background(row.isHeaderRow
                                ? Color.blue
                                : (isNeedHightlight(by: index) ? Color(hex: "#C1E3FF") : .white)
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .hideRowIndicator()
                    .clipped()
                }
                .environment(\.defaultMinListRowHeight, 10)
                .padding(0)
                .frame(width: CGFloat(table.numberOfColumns) * Constant.defaultColumnWidth,
                       height: Constant.defaultSchemeTableHeight
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Constant.tableCornerRadius).stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(Constant.tableCornerRadius)
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
                }
            }
            .padding(0)
            .listRowInsets(EdgeInsets())
            .hideRowIndicator()
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .listStyle(PlainListStyle())
    }
}

extension DBrowserMain {
    private enum Constant {
        static let defaultColumnWidth: CGFloat = 100
        static let defaultSchemeTableHeight: CGFloat = 300
        static let cellSeparatorWidth: CGFloat = 0.5
        static let tableCornerRadius: CGFloat = 5
    }

    private func isNeedHightlight(by index: Int) -> Bool {
        return index % 2 == 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DBrowserMain(container: .defaultValue, schemeTables: [])
    }
}
