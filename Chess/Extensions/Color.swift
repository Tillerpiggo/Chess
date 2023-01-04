//
//  Color+Extensions.swift
//  Chess
//
//  Created by Tyler Gee on 2/8/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import SwiftUI

extension Color {
    static var theme: Theme = DefaultTheme()
}

struct DefaultTheme: Theme {
    
    var background = Color("Background")

    var lightSquareColor = Color("LightSquareColor")
    
    var darkSquareColor = Color("DarkSquareColor")
    
    var accent = Color("Accent")
    
    var primary = Color("Primary")
    
    var secondary = Color("Secondary")
    
    var tertiary = Color("Tertiary")
    
    var primaryText = Color("TextColor")
    
    var secondaryText = Color("SecondaryTextColor")
    
    var darkPrimaryText = Color("PrimaryTextDark")
    
    var darkSecondaryText = Color("SecondaryTextDark")
    
    var buttonColor = Color("ButtonColor")
    
    var selectedSquareColor = Color("SelectedSquareColor")
    
    var excludedSquareColor = Color("ExcludedSquareColor")
    
}

protocol Theme {
    var background: Color { get }
    var lightSquareColor: Color { get }
    var darkSquareColor: Color { get }
    var accent: Color { get }
    var primary: Color { get }
    var secondary: Color { get }
    var tertiary: Color { get }
    var primaryText: Color { get }
    var secondaryText: Color { get }
    var darkPrimaryText: Color { get }
    var darkSecondaryText: Color { get }
    var buttonColor: Color { get }
    var selectedSquareColor: Color { get }
    var excludedSquareColor: Color { get }
} 
