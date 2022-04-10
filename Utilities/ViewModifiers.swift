//
//  ViewModifiers.swift
//  DBrowser
//
//  Created by Harley Pham on 13/03/2022.
//

import Foundation
import SwiftUI

struct ListRowSeparatorVisibility: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content.listRowSeparator(.hidden)
        }
        else {
            content.onAppear {
                UITableView.appearance().separatorStyle = .none
            }
        }
    }
}

struct NavigationBarTitle: ViewModifier {
    let title: String
    let displayMode: NavigationBarItem.TitleDisplayMode
    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.navigationTitle(title)
            content.navigationBarTitleDisplayMode(displayMode)
        }
        else {
            content.navigationBarTitle(Text(title), displayMode: displayMode)
        }
    }
}

struct CellWithBorder: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(
            Rectangle()
                .frame(width: Constants.cellSeparatorWidth, height: nil, alignment: .trailing)
                .foregroundColor(Color.gray),
            alignment: .trailing
        )
    }
}

extension View {
    func hideRowSeparator() -> some View {
        ModifiedContent(content: self, modifier: ListRowSeparatorVisibility())
    }
}

extension View {
    func compatNavigationTitle(_ title: String, displayMode mode: NavigationBarItem.TitleDisplayMode) -> some View {
        ModifiedContent(content: self, modifier: NavigationBarTitle(title: title, displayMode: mode))
    }
}

extension View {
    func overlayCellWithBorder() -> some View {
        ModifiedContent(content: self, modifier: CellWithBorder())
    }
}
