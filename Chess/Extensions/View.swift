//
//  View+Extensions.swift
//  Chess
//
//  Created by Tyler Gee on 8/28/22.
//  Copyright © 2022 Beaglepig. All rights reserved.
//

import SwiftUI

extension View {
    func frame(size: CGSize) -> some View {
        return self.frame(width: size.width, height: size.height)
    }
}
