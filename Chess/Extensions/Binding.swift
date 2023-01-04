//
//  Binding+Extensions.swift
//  Chess
//
//  Created by Tyler Gee on 7/7/22.
//  Copyright © 2022 Beaglepig. All rights reserved.
//

import SwiftUI

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}
