//
//  ApplicationController.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import Foundation

class ApplicationController {
    
    static func preview() -> ApplicationController {
        ApplicationController()
    }
    
    lazy var viewModel: ViewModel = {
        ViewModel(app: self)
    }()
}
