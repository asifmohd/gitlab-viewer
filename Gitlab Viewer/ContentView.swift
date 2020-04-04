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

struct MergeRequest: Codable, Identifiable {
    let id: Int
    let title: String
}

struct ProjectDetailsView: View {
    let project: Project
    let gitlabConfig: GitlabConfig
    @State var mergeRequests: [MergeRequest] = []

    var body: some View {
        List(mergeRequests) { mergeRequest in
            Text(mergeRequest.title)
        }
        .onAppear() {
            self.loadData()
        }
        .navigationBarTitle("Merge Requests")
    }

    func loadData() {
        guard let url = URL(string: "\(self.gitlabConfig.baseURL)/projects/\(self.project.id)/merge_requests") else {
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
                let mergeRequests = try decoder.decode([MergeRequest].self, from: dataU)
                DispatchQueue.main.async {
                    self.mergeRequests = mergeRequests
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

struct ProjectsList: View {
    @State private var projects: [Project] = []
    @State private var isLoading: Bool = false
    @State private var nextPageLink: String?
    let gitlabConfig: GitlabConfig
    let group: Int?

    var body: some View {
        List {
            ForEach(projects) { project in
                NavigationLink(destination: ProjectDetailsView(project: project, gitlabConfig: self.gitlabConfig)) {
                    Text(project.name)
                }
                .onAppear {
                    self.listItemDidAppear(project)
                }
            }
            if self.isLoading {
                Text("Loading more projects...")
            }
            if self.allProjectsLoaded() {
                Text("Fetched all projects, no more to fetch")
            }
        }
        .onAppear {
            self.loadData()
        }
        .navigationBarTitle("Projects")
    }

    // inspired from https://medium.com/better-programming/meet-greet-list-pagination-in-swiftui-8330ee15fd61
    private func listItemDidAppear(_ item: Project) {
        if self.projects.isLast(item: item) {
            self.loadData()
        }
    }

    private func allProjectsLoaded() -> Bool {
        return self.nextPageLink == nil && self.projects.count > 0
    }

    private func loadData() {
        guard !allProjectsLoaded() && !self.isLoading else {
            return
        }
        let urlString: String
        if let nextPageLink = self.nextPageLink {
            urlString = nextPageLink
        } else if let groupId = self.group {
            urlString = "\(self.gitlabConfig.baseURL)/groups/\(groupId)/projects?pagination=keyset&per_page=50&order_by=id&sort=asc"
        } else {
            // default to all projects if groupId does not exist
            urlString = "\(self.gitlabConfig.baseURL)/projects?pagination=keyset&per_page=50&order_by=id&sort=asc"
        }
        guard let url = URL(string: urlString) else {
            assertionFailure("Invalid url")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(self.gitlabConfig.authToken, forHTTPHeaderField: "Private-Token")
        self.isLoading = true
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let dataU = data else {
                print(error as Any)
                return
            }
            let decoder = JSONDecoder()
            do {
                let projects = try decoder.decode([Project].self, from: dataU)
                var nextPageLink: String?
                if let httpResponse = response as? HTTPURLResponse,
                    let linkHeader = httpResponse.allHeaderFields["Link"] as? String {
                    nextPageLink = self.getNextPageLink(from: linkHeader)
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.projects.append(contentsOf: projects)
                    self.nextPageLink = nextPageLink
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }

    private func getNextPageLink(from header: String) -> String? {
        let splitHeaderArray = header.split(separator: ",")
        guard let nextURLIndex = splitHeaderArray.firstIndex(where: { (string) in return string.contains("rel=\"next\"") }),
            let nextPageLink = splitHeaderArray[nextURLIndex].split(separator: ";").first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).trimmingCharacters(in: CharacterSet.init(charactersIn: "<>")) else {
            return nil
        }
        return nextPageLink
    }
}

struct GroupsView: View {
    struct Group: Codable, Identifiable {
        let id: Int
        let name: String
    }

    @State private var groups: [Group] = []
    let gitlabConfig: GitlabConfig

    var body: some View {
        List {
            ForEach(groups) { (group) in
                NavigationLink(destination: ProjectsList(gitlabConfig: self.gitlabConfig, group: group.id)) {
                    Text(group.name)
                }
            }
        }
        .onAppear {
            self.loadData()
        }
        .navigationBarTitle("Gitlab Groups")
    }

    func loadData() {
        guard let url = URL(string: "\(self.gitlabConfig.baseURL)/groups") else {
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
                let groups = try decoder.decode([Group].self, from: dataU)
                DispatchQueue.main.async {
                    self.groups = groups
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

struct ContentView: View {
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
        NavigationView {
            GroupsView(gitlabConfig: self.gitlabConfig)
        }
    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
