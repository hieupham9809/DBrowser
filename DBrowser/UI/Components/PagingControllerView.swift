//
//  PagingControllerView.swift
//  DBrowser
//
//  Created by Harley Pham on 24/03/2022.
//

import SwiftUI

struct PagingControllerView: View {
    @Binding var currentPage: Int?
    @Binding var totalPage: Int

    init(currentPage: Binding<Int?>, totalPage: Binding<Int>) {
        self._currentPage = currentPage
        self._totalPage = totalPage
    }

    var body: some View {
        if let currentPage = currentPage {
            HStack {
                Spacer()
                HStack(spacing: 10) {
                    Button(action: { firstPageButtonTapHandler() }, label: { Text("≪") })
                    Button(action: { previousPageButtonTapHandler() }, label: { Text("＜") })
                    if (currentPage > 2) {
                        Button(action: { selectPage(1) }, label: { Text("1") })
                        if (currentPage > 3) {
                            Text("...")
                        }
                    }
                    if (currentPage > 1) {
                        Button(action: { selectPage(currentPage - 1) }, label: { Text("\(currentPage - 1)") })
                    }
                    Button(action: { }, label: { Text("\(currentPage)").fontWeight(.heavy).underline() })
                    if (currentPage < totalPage - 1) {
                        Button(action: { selectPage(currentPage + 1) }, label: { Text("\(currentPage + 1)") })
                    }
                    if (currentPage < totalPage - 2) {
                        if (currentPage < totalPage - 3) {
                            Text("...")
                        }
                        Button(action: { selectPage(totalPage) }, label: { Text("\(totalPage)") })
                    }
                    Button(action: { nextPageButtonTapHandler() }, label: { Text("＞") })
                    Button(action: { lastPageButtonTapHandler() }, label: { Text("≫") })
                }
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        }
    }
}

// MARK: Button events
extension PagingControllerView {
    private func previousPageButtonTapHandler() {
        currentPage = max(1, (currentPage ?? 0) - 1)
    }

    private func firstPageButtonTapHandler() {
        currentPage = 1
    }

    private func nextPageButtonTapHandler() {
        currentPage = min(totalPage, (currentPage ?? 0) + 1)
    }

    private func lastPageButtonTapHandler() {
        currentPage = totalPage
    }

    private func selectPage(_ page: Int) {
        currentPage = page
    }
}

struct PagingController_Previews: PreviewProvider {
    @State static var currentPage: Int? = 3
    @State static var totalPage: Int = 10
    static var previews: some View {
        PagingControllerView(currentPage: $currentPage, totalPage: $totalPage)
    }
}
