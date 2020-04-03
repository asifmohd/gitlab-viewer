//
//  ContentView.swift
//  Gitlab Viewer
//
//  Created by Asif on 04/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import SwiftUI

struct Project: Codable, Identifiable {
    let id: Int
    let name: String
}

struct GitlabConfig: Codable {
    let baseURL: String
    let authToken: String

    enum CodingKeys: String, CodingKey {
        case baseURL = "BASE_URL"
        case authToken = "AUTH_TOKEN"
    }
}

struct ContentView: View {
    @State private var projects: [Project] = []
    private let gitlabConfig: GitlabConfig

    init() {
        guard let configPlistURL = Bundle.main.url(forResource: "Gitlab_configs", withExtension: "plist") else {
                fatalError("Could not find Gitlab_configs.plist")
        }
        let plistDecoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: configPlistURL)
            self.gitlabConfig = try plistDecoder.decode(GitlabConfig.self, from: data)
        } catch let error {
            fatalError("Failed to decode plist with error \(error)")
        }
    }

    var body: some View {
        VStack {
            List(projects) { project in
                Text(project.name)
            }.onAppear {
                self.loadData()
            }
        }
    }

    func loadData() {
        guard let url = URL(string: "\(self.gitlabConfig.baseURL)/projects") else {
            assertionFailure("Invalid url")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(self.gitlabConfig.authToken, forHTTPHeaderField: "Private-Token")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let dataU = data else {
                print(error as Any)
                return
            }
            let decoder = JSONDecoder()
            do {
                let projects = try decoder.decode([Project].self, from: dataU)
                DispatchQueue.main.async {
                    self.projects = projects
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
