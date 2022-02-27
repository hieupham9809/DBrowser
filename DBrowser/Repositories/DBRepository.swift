//
//  DBRepository.swift
//  DBrowser
//
//  Created by Harley Pham on 23/02/2022.
//

import Foundation
import Combine

protocol DBRepository {
    func loadSchemes() throws -> [DBDataTable]
}
