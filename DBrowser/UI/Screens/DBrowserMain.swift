//
//  DBrowserMain.swift
//  
//
//  Created by Harley Pham on 13/02/2022.
//

import SwiftUI
import Combine

struct DBrowserMain: View {
    private let container: DIContainer

    @State private(set) var schemeTables: Loadable<[DBDataTable]>

    init(container: DIContainer, schemeTables: [DBDataTable]) {
        self.container = container
        self._schemeTables = .init(initialValue: .loaded(schemeTables))
    }

    init(filePath: String) throws {
        let dbDataInteractor = try SQLiteDBDataInteractor(
            sqliteFileRepository: SQLiteFileRepository(path: filePath)
        )
        let interactors = DIContainer.Interactors(dbDataInteractor: dbDataInteractor)
        self.container = DIContainer(interactors: interactors)

        // temporary put the loading here due to a bug on SwiftUI's `onAppear`
        self._schemeTables = .init(initialValue: .loaded(container.interactors.dbDataInteractor.loadAllTableSchemes()))
    }

    var body: some View {
        NavigationView {
            self.content
        }
        .inject(container)
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
            VStack {
                HStack {
                    NavigationLink {
                        DBrowserTableDetails(table: table)
                    } label: {
                        Text("\(table.name)").font(Font.headline)
                    }
                }
                ScrollView(.horizontal) {
                    VStack(spacing: 0) {
                        ForEach(Array(zip(table.rows.indices, table.rows)), id: \.1.id) { index, row in
                            HStack(spacing: 0) {
                                ForEach(row.items, id: \.id) { item in
                                    Text("\(item.value)")
                                        .padding(4)
                                        .frame(width: Constants.defaultColumnWidth)
                                        .frame(maxHeight: .infinity)
                                        .foregroundColor(row.isHeaderRow ? Color.white : .black)
                                        .overlay(
                                            Rectangle()
                                                .frame(width: Constants.cellSeparatorWidth, height: nil, alignment: .trailing)
                                                .foregroundColor(Color.gray),
                                            alignment: .trailing
                                        )
                                }
                            }
                            .fixedSize()
                            .overlay(
                                Rectangle()
                                    .frame(width: nil, height: Constants.cellSeparatorWidth, alignment: .bottom)
                                    .foregroundColor(Color.gray),
                                alignment: .bottom
                            )
                            .background(row.isHeaderRow
                                        ? Color.blue
                                        : (isNeedHightlight(by: index) ? Color(hex: "#C1E3FF") : .white)
                            )
                            .clipped()
                        }
                        .padding(0)
                    }
                }
                .padding(0)
                .border(Color.gray, width: 0.5)
                .cornerRadius(Constants.tableCornerRadius)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.tableCornerRadius).stroke(Color.gray, lineWidth: 1)
                )
            }
            .hideRowSeparator()

        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("All scheme tables")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension DBrowserMain {
    private func isNeedHightlight(by index: Int) -> Bool {
        return index % 2 == 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DBrowserMain(container: .defaultValue, schemeTables: [])
    }
}
