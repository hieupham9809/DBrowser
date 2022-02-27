//
//  DBrowserMain.swift
//  
//
//  Created by Harley Pham on 13/02/2022.
//

import SwiftUI

public struct DBrowserMain: View {
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }
    public var body: some View {
        Text("Hello, world!ssdfas")
            .padding()
            .inject(container)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DBrowserMain(container: .defaultValue)
    }
}
