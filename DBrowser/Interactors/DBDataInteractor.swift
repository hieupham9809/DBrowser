//
//  DBDataInteractor.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation
import SwiftUI

protocol DBDataInteractor {
    func loadAllTableSchemes(schemes: Binding<[DBDataTable]>)
}

struct InitialDBDataInteractor: DBDataInteractor {
    func loadAllTableSchemes(schemes: Binding<[DBDataTable]>) { }
}
