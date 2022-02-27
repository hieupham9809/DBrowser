//
//  InteractorsContainer.swift
//  DBrowser
//
//  Created by Harley Pham on 27/02/2022.
//

import Foundation

extension DIContainer {
    struct Interactors {
        let dbDataInteractor: DBDataInteractor

        static var stub: Self {
            .init(dbDataInteractor: InitialDBDataInteractor())
        }
    }
}
