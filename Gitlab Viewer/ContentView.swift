//
//  ContentView.swift
//  Gitlab Viewer
//
//  Created by Asif on 04/04/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {

    var body: some View {
        NavigationView {
            GroupsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppSettings())
        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}
