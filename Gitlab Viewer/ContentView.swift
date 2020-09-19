//
//  ContentView.swift
//  Gitlab Viewer
//
//  Created by Asif on 04/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import SwiftUI
import Combine

struct MainMenuCell: View {
    let featureName: String
    var body: some View {
        Text(featureName)
    }
}

struct MainMenu: View {
    @State(initialValue: false) private var showSettings: Bool
    @EnvironmentObject var appSettings: AppSettings
    var body: some View {
        List {
            NavigationLink(destination: GroupsView()) {
                Text("Groups")
            }
            NavigationLink(destination: RunnerView()) {
                Text("Runners")
            }
        }.navigationBarTitle("Gitlab Viewer")
            .navigationBarItems(trailing:
                Button(action: {
                    self.showSettings = true
                }) {
                    HStack {
                        Image(systemName: "gear")
                    }
                }
        ).sheet(isPresented: $showSettings, onDismiss: {
            self.showSettings = false
        }) {
            AppSettingsView()
                .environmentObject(self.appSettings)
        }
    }
}

struct ContentView: View {

    var body: some View {
        NavigationView {
            MainMenu()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppSettings())
        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
