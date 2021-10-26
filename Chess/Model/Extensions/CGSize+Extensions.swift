//
//  CGRect.swift
//  Chess
//
//  Created by Tyler Gee on 8/2/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

import CoreGraphics

extension CGSize {
	var smallestSide: CGFloat {
		min(width, height)
	}
    
    var largestSide: CGFloat {
        max(width, height)
    }
    
    var distance: CGFloat {
        sqrt(pow(width, 2) + pow(height, 2))
    }

	static func +(lhs: Self, rhs: Self) -> CGSize {
		CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
	}
	static func -(lhs: Self, rhs: Self) -> CGSize {
		CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
	}
	static func *(lhs: Self, rhs: CGFloat) -> CGSize {
		CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
	}
	static func /(lhs: Self, rhs: CGFloat) -> CGSize {
		CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
	}
}
