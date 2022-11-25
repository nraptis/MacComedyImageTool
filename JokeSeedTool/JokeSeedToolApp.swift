//
//  JokeSeedToolApp.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import SwiftUI

@main
struct JokeSeedToolApp: App {
    let app = ApplicationController()
    var body: some Scene {
        WindowGroup {
            RootView(viewModel: app.viewModel)
        }
    }
}
