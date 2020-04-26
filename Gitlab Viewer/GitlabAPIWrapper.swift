//
//  GitlabAPIWrapper.swift
//  Gitlab Viewer
//
//  Created by Asif on 26/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation
import Combine

class GitlabAPIWrapper {
    let config: GitlabConfig
    let groupAPI: GroupAPI

    init() {
        guard let configPlistURL = Bundle.main.url(forResource: "Gitlab_configs", withExtension: "plist") else {
                fatalError("Could not find Gitlab_configs.plist")
        }
        let plistDecoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: configPlistURL)
            let gitlabConfig = try plistDecoder.decode(GitlabConfig.self, from: data)
            self.config = gitlabConfig
            self.groupAPI = GroupAPI(gitlabConfig: gitlabConfig)
        } catch let error {
            fatalError("Failed to decode plist with error \(error)")
        }
    }
}

class GroupAPI: ObservableObject {
    let publisher: AnyPublisher<[Group], Never>

    init(gitlabConfig: GitlabConfig) {
        guard let url = URL(string: "\(gitlabConfig.baseURL)/groups") else {
            assertionFailure("Invalid url")
            self.publisher = Empty<[Group], Never>(completeImmediately: true).eraseToAnyPublisher()
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(gitlabConfig.authToken, forHTTPHeaderField: "Private-Token")
        self.publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [Group].self, decoder: JSONDecoder())
            .catch({ (error) -> AnyPublisher<[Group], Never> in
                print("Groups API error: \(error)")
                return Empty<[Group], Never>(completeImmediately: true).eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
