//
//  FloatingControlView.swift
//  DBrowser
//
//  Created by Harley Pham on 02/05/2022.
//

import Foundation
import SwiftUI

enum ControlDisplayingMode {
    case compact
    case regular

    mutating func toggle() {
        if self == .compact {
            self = .regular
        }
        else {
            self = .compact
        }
    }
}

struct FloatingControlView: View {
    @State var mode: ControlDisplayingMode = .compact
    @State var main: DBrowserMain?

    init(filePath: String) {
        self._main = .init(initialValue: try? DBrowserMain(filePath: filePath))
    }

    var body: some View {
        ZStack {
            switch mode {
            case .regular:
                VStack(alignment: .center, spacing: 0) {
                    Button(action: { mode.toggle() }) {
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    if let main = main {
                        main
                    }
                    else {
                        Text("Error loading DB.")
                    }
                }
            case .compact:
                Button(action: { mode.toggle() }) {
                    Image(systemName: "list.bullet.rectangle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .cornerRadius(40)
                        .clipped()
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

    }
}

struct FloatingControlView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingControlView(filePath: "")
            .background(Color.gray)
    }
}

public final class Interface {
    public static func display(filePath: String) -> some View {
        FloatingControlView(filePath: filePath)
    }
}
