//
//  ProjectsListView.swift
//  Gitlab Viewer
//
//  Created by Asif on 26/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation
import SwiftUI

struct ProjectsList: View {
    @State private var projects: [Project] = []
    @State private var isLoading: Bool = false
    @State private var nextPageLink: String?
    @EnvironmentObject private var appSettings: AppSettings
    let group: Int?

    var body: some View {
        List {
            ForEach(projects) { project in
                NavigationLink(destination: ProjectDetailsView(project: project)) {
                    Text(project.name)
                }
                .onAppear {
                    self.listItemDidAppear(project)
                }
            }
            if self.isLoading {
                HStack {
                    Text("Loading more projects...")
                    ActivityIndicator(isAnimating: $isLoading, style: .medium)
                }
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
            urlString = "\(self.appSettings.gitlabAPI.config.baseURL)/groups/\(groupId)/projects?pagination=keyset&per_page=50&order_by=id&sort=asc"
        } else {
            // default to all projects if groupId does not exist
            urlString = "\(self.appSettings.gitlabAPI.config.baseURL)/projects?pagination=keyset&per_page=50&order_by=id&sort=asc"
        }
        guard let url = URL(string: urlString) else {
            assertionFailure("Invalid url")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(self.appSettings.gitlabAPI.config.authToken, forHTTPHeaderField: "Private-Token")
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
        let splitHeaderArray = header.split(separator: Character(","))
        guard let nextURLIndex = splitHeaderArray.firstIndex(where: { (string) in return string.contains("rel=\"next\"") }),
            let nextPageLink = splitHeaderArray[nextURLIndex].split(separator: ";").first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).trimmingCharacters(in: CharacterSet.init(charactersIn: "<>")) else {
            return nil
        }
        return nextPageLink
    }
}
