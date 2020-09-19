//
//  AppSettings.swift
//  Gitlab Viewer
//
//  Created by Asif on 28/06/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import SwiftUI
import Combine

struct AppSettingsView: View {
    @State(initialValue: "") private var instanceURL: String
    @State(initialValue: "") private var clientId: String
    @State(initialValue: "") private var clientSecret: String
    @State(initialValue: "") private var redirectURI: String
    @State(initialValue: "") private var code: String
    @EnvironmentObject var appSettings: AppSettings
    private let state: UUID = UUID()
    private let scope: String = "api"
    var body: some View {
        NavigationView {
            Form {
                VStack {
                    Section {
                        HStack {
                            TextField("Instance URL Example: https://gitlab.com", text: $instanceURL)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                        }.padding()
                        HStack {
                            TextField("Client ID", text: $clientId)
                                .keyboardType(.asciiCapable)
                                .autocapitalization(.none)
                        }.padding()
                        HStack {
                            TextField("Client Secret", text: $clientSecret)
                                .keyboardType(.asciiCapable)
                                .autocapitalization(.none)
                        }.padding()
                        HStack {
                            TextField("Redirect URI", text: $redirectURI)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                        }.padding()
                    }
                    Section {
                        Button("Connect") {
                            self.appSettings.setOAuthInfo(gitlabOAuthInfo: GitlabOAuthInfo(baseURL: self.instanceURL, clientId: self.clientId, clientSecret: self.clientSecret, redirectURI: self.redirectURI))
                            UIApplication.shared.open(URL(string: "\(self.instanceURL)/oauth/authorize?client_id=\(self.clientId)&redirect_uri=\(self.redirectURI)&response_type=code&state=\(self.state.uuidString)&scope=\(self.scope)")!)
                        }.disabled(self.instanceURL.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty || self.clientId.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty  || self.clientSecret.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty || self.redirectURI.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)
                    }
                }.onAppear {
                    print("")
                }
            }
        }.navigationBarTitle("Settings")
    }
}

struct AppSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppSettingsView()
        }
    }
}
