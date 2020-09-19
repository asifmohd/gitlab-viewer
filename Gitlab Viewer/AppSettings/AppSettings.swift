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

struct GitlabUserDefaultKeys {
    static let instanceURL: String = "gitlab_instance_url"
    static let authToken: String = "gitlab_auth_token"
    static let clientId: String = "gitlab_client_id"
    static let clientSecret: String = "gitlab_client_secret"
    static let redirectURI: String = "gitlab_redirect_uri"
}

struct GitlabOAuthResponse: Codable {
    let accessToken: String
}

class AppSettings: ObservableObject {
    private(set) var gitlabAPI: GitlabAPIWrapper!
    private(set) var gitlabOAuthInfo: GitlabOAuthInfo?

    init() {
        guard let instanceURL: String = UserDefaults.standard.string(forKey: GitlabUserDefaultKeys.instanceURL),
            let authToken: String = UserDefaults.standard.string(forKey: GitlabUserDefaultKeys.authToken),
            let clientId = UserDefaults.standard.string(forKey: GitlabUserDefaultKeys.clientId),
            let clientSecret = UserDefaults.standard.string(forKey: GitlabUserDefaultKeys.clientSecret),
            let redirectURI = UserDefaults.standard.string(forKey: GitlabUserDefaultKeys.redirectURI) else {
            return
        }
        gitlabAPI = GitlabAPIWrapper(connectionInfo: GitlabConnectionInfo(instanceURL: instanceURL, authToken: authToken))
        gitlabOAuthInfo = GitlabOAuthInfo(instanceURL: instanceURL, clientId: clientId, clientSecret: clientSecret, redirectURI: redirectURI)
    }

    func getAuthToken(from code: String) throws {
        guard let gitlabOAuthInfo = gitlabOAuthInfo else {
            throw AppSettingsError.oauthInfoNotFound
        }
        guard let url = URL(string: "\(gitlabOAuthInfo.instanceURL)/oauth/token") else {
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
            UserDefaults.standard.set(oAuthResponse.accessToken, forKey: GitlabUserDefaultKeys.authToken)
            let connectionInfo = GitlabConnectionInfo(instanceURL: gitlabOAuthInfo.instanceURL, authToken: oAuthResponse.accessToken)
            self?.gitlabAPI = GitlabAPIWrapper(connectionInfo: connectionInfo)
        })
        request.resume()
    }

    func setOAuthInfo(gitlabOAuthInfo: GitlabOAuthInfo) {
        self.gitlabOAuthInfo = gitlabOAuthInfo
        UserDefaults.standard.set(gitlabOAuthInfo.instanceURL, forKey: GitlabUserDefaultKeys.instanceURL)
        UserDefaults.standard.set(gitlabOAuthInfo.clientId, forKey: GitlabUserDefaultKeys.clientId)
        UserDefaults.standard.set(gitlabOAuthInfo.clientSecret, forKey: GitlabUserDefaultKeys.clientSecret)
        UserDefaults.standard.set(gitlabOAuthInfo.redirectURI, forKey: GitlabUserDefaultKeys.redirectURI)

    }
}
