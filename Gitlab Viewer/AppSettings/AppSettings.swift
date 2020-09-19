//
//  AppSettings.swift
//  Gitlab Viewer
//
//  Created by Asif on 26/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation

enum AppSettingsError: Error {
    case oauthInfoNotFound
    case invalidInstanceURL
    case oauthErrorFromGitlab
    case oauthErrorDataIsNil
}

struct GitlabOAuthResponse: Codable {
    let accessToken: String
}

class AppSettings: ObservableObject {
    private(set) var gitlabAPI: GitlabAPIWrapper!
    private(set) var gitlabOAuthInfo: GitlabOAuthInfo?

    init() {
        guard let baseURL: String = UserDefaults.standard.string(forKey: "gitlab_base_url"),
            let authToken: String = UserDefaults.standard.string(forKey: "gitlab_auth_token"),
            let clientId = UserDefaults.standard.string(forKey: "gitlab_client_id"),
            let clientSecret = UserDefaults.standard.string(forKey: "gitlab_client_secret"),
            let redirectURI = UserDefaults.standard.string(forKey: "gitlab_redirect_uri") else {
            return
        }
        gitlabAPI = GitlabAPIWrapper(connectionInfo: GitlabConnectionInfo(baseURL: baseURL, authToken: authToken))
        gitlabOAuthInfo = GitlabOAuthInfo(baseURL: baseURL, clientId: clientId, clientSecret: clientSecret, redirectURI: redirectURI)
    }

    func getAuthToken(from code: String) throws {
        guard let gitlabOAuthInfo = gitlabOAuthInfo else {
            throw AppSettingsError.oauthInfoNotFound
        }
        guard let url = URL(string: "\(gitlabOAuthInfo.baseURL)/oauth/token") else {
            throw AppSettingsError.invalidInstanceURL
        }

        var urlRequest = URLRequest(url: url)
        let params = "client_id=\(gitlabOAuthInfo.clientId)&client_secret=\(gitlabOAuthInfo.clientSecret)&code=\(code)&grant_type=authorization_code&redirect_uri=\(gitlabOAuthInfo.redirectURI)"
        urlRequest.httpBody = params.data(using: .utf8)
        urlRequest.httpMethod = "POST"
        let request = URLSession.shared.dataTask(with: urlRequest, completionHandler: { [weak self] (data, response, error) in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
            guard let oAuthResponse = try? decoder.decode(GitlabOAuthResponse.self, from: data) else {
                return
            }
            let connectionInfo = GitlabConnectionInfo(baseURL: gitlabOAuthInfo.baseURL, authToken: oAuthResponse.accessToken)
            self?.gitlabAPI = GitlabAPIWrapper(connectionInfo: connectionInfo)
        })
        request.resume()
    }

    func setOAuthInfo(gitlabOAuthInfo: GitlabOAuthInfo) {
        self.gitlabOAuthInfo = gitlabOAuthInfo
    }
}
