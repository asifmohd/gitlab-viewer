//
//  RunnerDetailView.swift
//  Gitlab Viewer
//
//  Created by Mohammad Asif on 17/10/20.
//  Copyright © 2020 Asif. All rights reserved.
//

import SwiftUI

struct RunnerDetailView: View {
    let runner: Runner
    var body: some View {
        Text(runner.description)
    }
}
