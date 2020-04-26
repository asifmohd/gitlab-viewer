//
//  GitlabConfigModel.swift
//  Gitlab Viewer
//
//  Created by Asif on 26/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation

struct GitlabConfig: Codable {
    let baseURL: String
    let authToken: String

    enum CodingKeys: String, CodingKey {
        case baseURL = "BASE_URL"
        case authToken = "AUTH_TOKEN"
    }
}
