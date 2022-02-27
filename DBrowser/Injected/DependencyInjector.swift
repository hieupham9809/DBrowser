//
//  DependencyInjector.swift
//  DBrowser
//
//  Created by Harley Pham on 27/02/2022.
//

import Foundation
import SwiftUI

// MARK: - DIContainer

struct DIContainer: EnvironmentKey {
    let interactors: Interactors

    static var defaultValue: Self { Self.default }

    private static let `default` = Self(interactors: .stub)
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

// MARK: - Injection in the view hierarchy

extension View {
    func inject(_ container: DIContainer) -> some View {
        return self.environment(\.injected, container)
    }
}
