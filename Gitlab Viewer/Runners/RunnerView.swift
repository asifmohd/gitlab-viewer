//
//  RunnerView.swift
//  Gitlab Viewer
//
//  Created by Asif on 20/06/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import SwiftUI
import Combine

struct Runner: Codable, Identifiable {
    let id: Int
    let description: String
    let active: Bool
    let online: Bool
    let status: String
}

enum RunnerToModify {
    case runner(id: Int, active: Bool)
    case none
}

struct RunnerDetailView: View {
    let runner: Runner
    var body: some View {
        Text(runner.description)
    }
}

struct RunnerStatusView: View {
    enum Mode {
        case active(online: Bool)
        case inactive(online: Bool)

        func color() -> Color {
            switch self {
            case .active(let online):
                if online {
                    return Color.green
                } else {
                    return Color.gray
                }
            case .inactive(let online):
                if online {
                    return Color.red
                } else {
                    return Color.gray
                }
            }
        }

        init(active: Bool, online: Bool) {
            if active {
                self = .active(online: online)
            } else {
                self = .inactive(online: online)
            }
        }
    }
    let mode: Mode
    var body: some View {
        Circle()
            .fill(mode.color())
            .frame(width: 24, height: 24)
    }
}

struct RunnerCellView: View {
    @Binding var displayMode: UInt
    var runnerToModifyHolder: RunnerToModifyInfo
    let runner: Runner

    private func buttonActionText() -> String {
        switch RunnerListView.DisplayMode(rawValue: self.displayMode)! {
        case .modify:
            if runner.active {
                return "Disable"
            } else {
                return "Enable"
            }
        case .details:
            return ""
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(runner.description)
            HStack {
                RunnerStatusView(mode: RunnerStatusView.Mode(active: runner.active, online: runner.online))
                Text("\(runner.status)")
                Spacer()
                Button(self.buttonActionText()) {
                    switch RunnerListView.DisplayMode(rawValue: self.displayMode)! {
                    case .modify:
                        self.runnerToModifyHolder.runnerToModify = .runner(id: self.runner.id, active: !self.runner.active)
                    case .details:
                        break
                    }
                }.padding(.trailing, 20)
            }
        }

    }
}

struct RunnerListView: View {

    enum DisplayMode: UInt {
        case modify
        case details
    }

    @State private var mode = DisplayMode.modify.rawValue
    let runnerList: [Runner]
    var runnerToModifyHolderBinding: RunnerToModifyInfo
    var body: some View {
        VStack {
            Picker(selection: $mode, label: Text("Select a display mode")) {
                Text("Modify").tag(DisplayMode.modify.rawValue)
                Text("View Details").tag(DisplayMode.details.rawValue)
            }.pickerStyle(SegmentedPickerStyle())
            ForEach(runnerList) { (runner) in
                RunnerCellView(displayMode: self.$mode, runnerToModifyHolder: self.runnerToModifyHolderBinding, runner: runner)
            }
        }
    }
}

class RunnerToModifyInfo: ObservableObject {
    @Published var runnerToModify: RunnerToModify = .none
}

class RunnerViewAPIHolder {
    var cancellable: Cancellable?
}

struct RunnerView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @State(initialValue: []) private var runnerList: [Runner]
    @State(initialValue: true) private var isLoading: Bool
    @ObservedObject private var modifyRunnerStateButtonTapped: RunnerToModifyInfo = RunnerToModifyInfo()
    let runnerViewAPIHolder: RunnerViewAPIHolder = RunnerViewAPIHolder()

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
                RunnerListView(runnerList: runnerList, runnerToModifyHolderBinding: modifyRunnerStateButtonTapped)
            }
        }.navigationBarTitle("Runners")
            .onReceive(appSettings.gitlabAPI.modifyRunnerAPI.publisher) { (runner) in
                guard let index = self.runnerList.firstIndex(where: { $0.id == runner.id }) else {
                    assertionFailure("Could not find runner which was being modified")
                    self.modifyRunnerStateButtonTapped.runnerToModify = .none
                    return
                }
                self.runnerList[index] = runner
                self.modifyRunnerStateButtonTapped.runnerToModify = .none
        }.onReceive(self.modifyRunnerStateButtonTapped.$runnerToModify) { (runnerToModify) in
            switch runnerToModify {
            case .runner(id: let runnerId, active: let activeFieldValue):
                self.appSettings.gitlabAPI.modifyRunnerAPI.runnerId = runnerId
                self.appSettings.gitlabAPI.modifyRunnerAPI.activeFieldValue = activeFieldValue
                self.appSettings.gitlabAPI.modifyRunnerAPI.makeRequest()
            case .none:
                break
            }
        }.onAppear {
            self.runnerViewAPIHolder.cancellable = self.appSettings.gitlabAPI.runnerAPI.publisher.sink(receiveValue: { (runners) in
                self.runnerList = runners
                self.isLoading = false
            })
        }
    }
}

#if DEBUG
struct RunnerView_Preview: PreviewProvider {
    static let runners: [Runner] = [
        Runner(id: 1, description: "Runner 1", active: true, online: true, status: "Online"),
        Runner(id: 2, description: "Runner 2", active: true, online: false, status: "Offline"),
        Runner(id: 3, description: "Runner 3", active: false, online: true, status: "Paused")]
    @State(initialValue: RunnerToModifyInfo()) private static var runnerToModifyHolder: RunnerToModifyInfo
    static var previews: some View {
        NavigationView {
            List {
                RunnerListView(runnerList: runners, runnerToModifyHolderBinding: runnerToModifyHolder)
            }.navigationBarTitle("Runners")
        }
    }
}
#endif
