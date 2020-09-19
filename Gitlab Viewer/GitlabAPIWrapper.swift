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
    let connectionInfo: GitlabConnectionInfo
    let config: GitlabConfig
    let groupAPI: GroupAPI
    let runnerAPI: RunnerAPI
    let modifyRunnerAPI: ModifyRunnerStatusAPI

    init(connectionInfo: GitlabConnectionInfo) {
        guard let configPlistURL = Bundle.main.url(forResource: "Gitlab_configs", withExtension: "plist") else {
                fatalError("Could not find Gitlab_configs.plist")
        }
        self.connectionInfo = connectionInfo
        let plistDecoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: configPlistURL)
            let gitlabConfig = try plistDecoder.decode(GitlabConfig.self, from: data)
            self.config = gitlabConfig
            self.groupAPI = GroupAPI(gitlabConnInfo: connectionInfo)
            self.runnerAPI = RunnerAPI(gitlabConnInfo: connectionInfo, gitlabConfig: gitlabConfig)
            self.modifyRunnerAPI = ModifyRunnerStatusAPI(gitlabConnInfo: connectionInfo)
        } catch let error {
            fatalError("Failed to decode plist with error \(error)")
        }
    }
}

class GroupAPI: ObservableObject {
    let publisher: AnyPublisher<[Group], Never>

    init(gitlabConnInfo: GitlabConnectionInfo) {
        guard let url = URL(string: "\(gitlabConnInfo.baseURL)/groups") else {
            assertionFailure("Invalid url")
            self.publisher = Empty<[Group], Never>(completeImmediately: true).eraseToAnyPublisher()
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(gitlabConnInfo.authToken)", forHTTPHeaderField: "Authorization")
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

class RunnerAPI: ObservableObject {
    let publisher: AnyPublisher<[Runner], Never>

    init(gitlabConnInfo: GitlabConnectionInfo, gitlabConfig: GitlabConfig) {
        guard let url = URL(string: "\(gitlabConnInfo.baseURL)/projects/\(gitlabConfig.projectIdForRunner)/runners?tag_list=\(gitlabConfig.tagFilterForRunner)") else {
            assertionFailure("Invalid url")
            self.publisher = Empty<[Runner], Never>(completeImmediately: true).eraseToAnyPublisher()
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(gitlabConnInfo.authToken)", forHTTPHeaderField: "Authorization")
        self.publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [Runner].self, decoder: JSONDecoder())
            .catch({ (error) -> AnyPublisher<[Runner], Never> in
                print("Runner API error: \(error)")
                return Empty<[Runner], Never>(completeImmediately: true).eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class ModifyRunnerStatusAPI: ObservableObject {
    var publisher: AnyPublisher<Runner, Never>
    let gitlabConnInfo: GitlabConnectionInfo
    var activeFieldValue: Bool = false
    var runnerId: Int?

    init(gitlabConnInfo: GitlabConnectionInfo) {
        self.gitlabConnInfo = gitlabConnInfo
        self.publisher = Empty<Runner, Never>(completeImmediately: true).eraseToAnyPublisher()
    }

    func makeRequest() {
        guard let runnerId = self.runnerId,
            let requestURL = URL(string: "\(gitlabConnInfo.baseURL)/runners/\(runnerId)") else {
            self.publisher = Empty<Runner, Never>(completeImmediately: true).eraseToAnyPublisher()
            return
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "PUT"
        urlRequest.httpBody = "active=\(activeFieldValue)".data(using: .utf8)
        urlRequest.setValue("Bearer \(gitlabConnInfo.authToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: Runner.self, decoder: JSONDecoder())
            .catch({ (error) -> AnyPublisher<Runner, Never> in
                print("Modify runner API error: \(error)")
                return Empty<Runner, Never>(completeImmediately: true).eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
