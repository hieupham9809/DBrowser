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

protocol FloatingControlViewDelegate: AnyObject {
    func didChangeToMode(_ mode: ControlDisplayingMode)
    func didClose()
}

struct FloatingControlView: View {
    @State var mode: ControlDisplayingMode = .compact
    @State var main: DBrowserMain?
    weak var delegate: FloatingControlViewDelegate?

    init(filePath: String, delegate: FloatingControlViewDelegate?) {
        self._main = .init(initialValue: try? DBrowserMain(filePath: filePath))
        self.delegate = delegate
    }

    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center, spacing: 0) {
                Button(action: {
                    mode.toggle()
                    delegate?.didChangeToMode(mode)
                }) {
                    Image(systemName: "chevron.down")
                }
                .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                if let main = main {
                    main
                }
                else {
                    Text("Error loading DB.")
                }
            }
            .padding(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
            .background(Color.white)
            if mode == .compact {
                VStack {
                    Button(action: {
                        mode.toggle()
                        delegate?.didChangeToMode(mode)
                    }) {
                        Circle()
                            .frame(width: Self.size, height: Self.size)
                            .background(Color.white)
                            .foregroundColor(Color.blue)
                            .cornerRadius(Self.size / 2)
                            .clipped()
                            .overlay(
                                Text("DB")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            )

                    }
                    .buttonStyle(StaticButtonStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .cornerRadius(mode == .compact ? Self.size / 2 : 0)
        .clipped()
        .animation(nil)
        .ignoresSafeArea()
    }
}

extension FloatingControlView {
    static let size: CGFloat = 80
}

struct FloatingControlView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingControlView(filePath: "", delegate: nil)
            .background(Color.gray)
    }
}
