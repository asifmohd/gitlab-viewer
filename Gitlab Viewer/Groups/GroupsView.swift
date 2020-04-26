//
//  GroupsView.swift
//  Gitlab Viewer
//
//  Created by Asif on 26/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import Foundation
import SwiftUI

struct GroupsView: View {

    @EnvironmentObject private var appSettings: AppSettings
    @State private var groups: [Group] = []

    var body: some View {
        List {
            ForEach(groups) { (group) in
                NavigationLink(destination: ProjectsList(group: group.id)) {
                    Text(group.name)
                }
            }
        }
        .navigationBarTitle("Gitlab Groups")
        .onReceive(self.appSettings.gitlabAPI.groupAPI.publisher) { (groups) in
            self.groups = groups
        }
    }
}
