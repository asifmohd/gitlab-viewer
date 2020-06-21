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
    let runnerAPI: RunnerAPI
    let modifyRunnerAPI: ModifyRunnerStatusAPI

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
            self.runnerAPI = RunnerAPI(gitlabConfig: gitlabConfig)
            self.modifyRunnerAPI = ModifyRunnerStatusAPI(gitlabConfig: gitlabConfig)
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

class RunnerAPI: ObservableObject {
    let publisher: AnyPublisher<[Runner], Never>

    init(gitlabConfig: GitlabConfig) {
        guard let url = URL(string: "\(gitlabConfig.baseURL)/projects/\(gitlabConfig.projectIdForRunner)/runners?tag_list=\(gitlabConfig.tagFilterForRunner)") else {
            assertionFailure("Invalid url")
            self.publisher = Empty<[Runner], Never>(completeImmediately: true).eraseToAnyPublisher()
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(gitlabConfig.authToken, forHTTPHeaderField: "Private-Token")
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
    let gitlabConfig: GitlabConfig
    var activeFieldValue: Bool = false
    var runnerId: Int?

    init(gitlabConfig: GitlabConfig) {
        self.gitlabConfig = gitlabConfig
        self.publisher = Empty<Runner, Never>(completeImmediately: true).eraseToAnyPublisher()
    }

    func makeRequest() {
        guard let runnerId = self.runnerId,
            let requestURL = URL(string: "\(gitlabConfig.baseURL)/runners/\(runnerId)") else {
            self.publisher = Empty<Runner, Never>(completeImmediately: true).eraseToAnyPublisher()
            return
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "PUT"
        urlRequest.httpBody = "active=\(activeFieldValue)".data(using: .utf8)
        urlRequest.setValue(gitlabConfig.authToken, forHTTPHeaderField: "Private-Token")
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
