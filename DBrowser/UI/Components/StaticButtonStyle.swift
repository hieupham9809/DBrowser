//
//  StaticButtonStyle.swift
//  DBrowser
//
//  Created by Harley Pham on 15/05/2022.
//

import SwiftUI

struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
