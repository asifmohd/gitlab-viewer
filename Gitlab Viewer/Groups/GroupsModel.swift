//
//  GroupsModel.swift
//  Gitlab Viewer
//
//  Created by Asif on 25/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation

struct Group: Codable, Identifiable {
    let id: Int
    let name: String
}
