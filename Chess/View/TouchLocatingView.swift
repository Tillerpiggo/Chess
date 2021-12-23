//
//  TouchLocatingView.swift
//  Chess
//
//  Created by Tyler Gee on 11/26/21.
//  Copyright © 2021 Beaglepig. All rights reserved.
//

// From: https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-the-location-of-a-tap-inside-a-view

import SwiftUI

// Our UIKit to SwiftUI wrapper view
struct TouchLocatingView: UIViewRepresentable {
    // The types of touches users want to be notified about
    struct TouchType: OptionSet {
        let rawValue: Int

        static let started = TouchType(rawValue: 1 << 0)
        static let moved = TouchType(rawValue: 1 << 1)
        static let ended = TouchType(rawValue: 1 << 2)
        static let all: TouchType = [.started, .moved, .ended]
        static let startOrEnd: TouchType = [.started, .ended]
    }

    // A closer to call when touch data has arrived
    var onUpdate: (CGPoint, TouchType) -> Void

    // The list of touch types to be notified of
    var types = TouchType.all

    // Whether touch information should continue after the user's finger has left the view
    var limitToBounds = true
    
    // The size of the view itself
    var size: CGSize = .zero

    func makeUIView(context: Context) -> TouchLocatingUIView {
        // Create the underlying UIView, passing in our configuration
        let view = TouchLocatingUIView()
        view.onUpdate = onUpdate
        view.touchTypes = types
        view.limitToBounds = limitToBounds
        view.size = size
        
        return view
    }

    func updateUIView(_ uiView: TouchLocatingUIView, context: Context) {
        uiView.setNeedsDisplay()
        uiView.setNeedsLayout()
        
        
        print("uiView.frame: \(uiView.frame)")
    }

    // The internal UIView responsible for catching taps
    class TouchLocatingUIView: UIView {
        // Internal copies of our settings
        var onUpdate: ((CGPoint, TouchType) -> Void)?
        var touchTypes: TouchLocatingView.TouchType = .all
        var limitToBounds = true
        var size: CGSize = .zero
        
        private var startLocation: CGPoint?

        // Our main initializer, making sure interaction is enabled.
        override init(frame: CGRect) {
            print("frame: \(frame)")
            super.init(frame: frame)
            isUserInteractionEnabled = true
        }

        // Just in case you're using storyboards!
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            isUserInteractionEnabled = true
        }

        // Triggered when a touch starts.
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .started)
            startLocation = location
        }

        // Triggered when an existing touch moves.
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .moved)
        }

        // Triggered when the user lifts a finger.
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            print("touchesEnded")
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .ended)
        }

        // Triggered when the user's touch is interrupted, e.g. by a low battery alert.
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            //send(location, forEvent: .ended) don't want this to trigger touches
        }

        // Send a touch location only if the user asked for it
        func send(_ location: CGPoint, forEvent event: TouchLocatingView.TouchType) {
            guard touchTypes.contains(event) else {
                return
            }

            if limitToBounds == false || bounds.contains(location) {
                onUpdate?(CGPoint(x: round(location.x), y: round(location.y)), event)
            }
        }
    }
}

// A custom SwiftUI view modifier that overlays a view with our UIView subclass.
struct TouchLocater: ViewModifier {
    var type: TouchLocatingView.TouchType = .all
    var limitToBounds = true
    //var size: CGSize = .zero
    let perform: (CGPoint, TouchLocatingView.TouchType) -> Void
    
    func offset(in size: CGSize) -> CGSize {
        var offsetRect: CGSize = .zero
        
        // Shift the longer dimension by half the difference between the dimensions
        let offset = (size.largestSide - size.smallestSide) / 2
        if size.width > size.height {
            offsetRect.width = offset
        } else {
            offsetRect.height = offset
        }
        
        return offsetRect
    }

    func body(content: Content) -> some View {
        GeometryReader { g in
            content
                .overlay(
                    ZStack {
                        TouchLocatingView(onUpdate: perform, types: type, limitToBounds: limitToBounds)
                            
//                        Rectangle()
//                            .fill(Color.blue)
//                            .opacity(0.4)
//                            .allowsHitTesting(false)
                    }
                        //.offset(offset(in: g.size))
                        //.frame(width: g.size.width, height: g.size.height)
                    
                )
        }
    }
}

// A new method on View that makes it easier to apply our touch locater view.
extension View {
    func onTouch(type: TouchLocatingView.TouchType = .all, limitToBounds: Bool = true, perform: @escaping (CGPoint, TouchLocatingView.TouchType) -> Void) -> some View {
        self.modifier(TouchLocater(type: type, limitToBounds: limitToBounds, perform: perform))
    }
}

//// Finally, here's some example code you can try out.
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Text("This will track all touches, inside bounds only.")
//                .padding()
//                .background(.red)
//                .onTouch(perform: updateLocation)
//
//            Text("This will track all touches, ignoring bounds – you can start a touch inside, then carry on moving it outside.")
//                .padding()
//                .background(.blue)
//                .onTouch(limitToBounds: false, perform: updateLocation)
//
//            Text("This will track only starting touches, inside bounds only.")
//                .padding()
//                .background(.green)
//                .onTouch(type: .started, perform: updateLocation)
//        }
//    }
//
//    func updateLocation(_ location: CGPoint, _ type: TouchLocatingView.TouchType) {
//        print(location)
//    }
//}
