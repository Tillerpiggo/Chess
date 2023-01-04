//
//  PreviewProviders.swift
//  Chess
//
//  Created by Tyler Gee on 12/26/22.
//  Copyright © 2022 Beaglepig. All rights reserved.
//

import Foundation
import SwiftUI

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}

class DeveloperPreview {
    
    static let instance = DeveloperPreview()
    private init() { }
    
    let gameManager = MockGameManager()
}
