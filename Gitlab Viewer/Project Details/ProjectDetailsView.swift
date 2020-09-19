//
//  ProjectDetailsView.swift
//  Gitlab Viewer
//
//  Created by Asif on 26/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation
import SwiftUI

struct ProjectDetailsView: View {
    let project: Project
    @EnvironmentObject private var appSettings: AppSettings
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
        guard let url = URL(string: "\(self.appSettings.gitlabAPI.connectionInfo.baseURL)/projects/\(self.project.id)/merge_requests") else {
            assertionFailure("Invalid url")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(self.appSettings.gitlabAPI.connectionInfo.authToken, forHTTPHeaderField: "Private-Token")
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
