//
//  GitlabConfigModel.swift
//  Gitlab Viewer
//
//  Created by Asif on 26/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation

struct GitlabConnectionInfo {
    let baseURL: String
    let authToken: String

    init(instanceURL: String, authToken: String) {
        self.baseURL = [instanceURL, "/api/v4"].joined()
        self.authToken = authToken
    }
}

struct GitlabConfig: Codable {
    let projectIdForRunner: String
    let tagFilterForRunner: String

    enum CodingKeys: String, CodingKey {
        case projectIdForRunner = "PROJECT_ID_TO_FETCH_RUNNERS_FROM"
        case tagFilterForRunner = "TAG_FILTER_FOR_RUNNER_API"
    }
}

struct GitlabOAuthInfo {
    let instanceURL: String
    let clientId: String
    let clientSecret: String
    let redirectURI: String
}
