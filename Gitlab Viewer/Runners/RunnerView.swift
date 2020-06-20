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
    let name: String
}

struct RunnerDetailView: View {
    let name: String
    var body: some View {
        Text(name)
    }
}

struct RunnerView: View {
    init(runnerList: [Runner] = []) {
        self.runnerList = runnerList
    }

    private var runnerList: [Runner]
    @State private var isLoading: Bool = true
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
                ForEach(runnerList) { (runner) in
                    NavigationLink(destination: RunnerDetailView(name: runner.name)) {
                        Text(runner.name)
                    }
                }
            }
        }.navigationBarTitle("Runners")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.isLoading = false
                }
        }
    }
}

#if DEBUG
struct RunnerView_Preview: PreviewProvider {
    static let runners: [Runner] = [
        Runner(id: 1, name: "Runner 1"),
        Runner(id: 2, name: "Runner 2")]
    static var previews: some View {
        NavigationView {
            RunnerView(runnerList: runners)
        }
    }
}
#endif
