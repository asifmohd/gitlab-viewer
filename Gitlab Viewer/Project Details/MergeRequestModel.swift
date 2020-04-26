//
//  MergeRequestModel.swift
//  Gitlab Viewer
//
//  Created by Asif on 26/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation

struct MergeRequest: Codable, Identifiable {
    let id: Int
    let title: String
}
