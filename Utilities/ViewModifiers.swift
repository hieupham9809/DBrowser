//
//  ViewModifiers.swift
//  DBrowser
//
//  Created by Harley Pham on 13/03/2022.
//

import Foundation
import SwiftUI

struct ListRowIndicatorVisibility: ViewModifier {
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

extension View {
    func hideRowIndicator() -> some View {
        ModifiedContent(content: self, modifier: ListRowIndicatorVisibility())
    }
}
