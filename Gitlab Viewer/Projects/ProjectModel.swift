//
//  ProjectModel.swift
//  Gitlab Viewer
//
//  Created by Asif on 26/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation

struct Project: Codable, Identifiable {
    let id: Int
    let name: String
}
