//
//  RunnerView.swift
//  Gitlab Viewer
//
//  Created by Asif on 20/06/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import SwiftUI

struct Runner: Codable, Identifiable {
    let id: Int
    let description: String
    let active: Bool
    let online: Bool
    let status: String
}

struct RunnerDetailView: View {
    let name: String
    var body: some View {
        Text(name)
    }
}

struct RunnerListView: View {
    let runnerList: [Runner]
    var body: some View {
        ForEach(runnerList) { (runner) in
            NavigationLink(destination: RunnerDetailView(name: runner.description)) {
                Text(runner.description)
            }
        }
    }
}

struct RunnerView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @State(initialValue: []) private var runnerList: [Runner]
    @State(initialValue: true) private var isLoading: Bool
    var body: some View {
        List {
            if self.isLoading {
                HStack {
                    Spacer()
                    Text("Loading runner information")
                    ActivityIndicator(isAnimating: $isLoading, style: .medium)
                    Spacer()
                }
            } else {
                RunnerListView(runnerList: runnerList)
            }
        }.navigationBarTitle("Runners")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.isLoading = false
                }
        }.onReceive(appSettings.gitlabAPI.runnerAPI.publisher) { (runners) in
            self.isLoading = false
            self.runnerList = runners
        }
    }
}

#if DEBUG
struct RunnerView_Preview: PreviewProvider {
    static let runners: [Runner] = [
        Runner(id: 1, description: "Runner 1", active: true, online: true, status: "Online"),
        Runner(id: 2, description: "Runner 2", active: true, online: false, status: "Offline"),
        Runner(id: 3, description: "Runner 3", active: false, online: true, status: "Paused")]
    static var previews: some View {
        NavigationView {
            List {
                RunnerListView(runnerList: runners)
            }.navigationBarTitle("Runners")
        }
    }
}
#endif
