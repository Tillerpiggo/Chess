//
//  PieceMovementEditorView.swift
//  Chess
//
//  Created by Tyler Gee on 6/23/22.
//  Copyright © 2022 Beaglepig. All rights reserved.
//

import SwiftUI

struct PieceMovementEditorView: View {
    @StateObject var moverManager: MoverManager
    @ObservedObject var viewModel: PieceMovementEditorViewModel
    
    @State var isAddPatternViewShowing = false
    
    private let lengthPercent: CGFloat = 0.82//0.908 // percent of the width that views in the list take up
    private let totalMargin: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: -2) {
                ZStack {
                    Rectangle()
                        .fill(Color.backgroundColor)
                        .frame(height: 60)
                    Picker("test", selection: $viewModel.selectedMovementType) {
                        ForEach(viewModel.movementTypes, id: \.self) { type in
                            Text(type.string)
                        }
                    }
                    .padding()
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                List {
                    
                    // TODO: somehow refcator this, especially lengthPercent and totalMargin
                    Section {
                        HStack {
                            Spacer()
                            BoardView2(
                                board: .constant(viewModel.board),
                                selectedSquares: viewModel.selectedSquares,
                                squareLength: (geometry.size.width * lengthPercent - totalMargin) / CGFloat(viewModel.board.files),
                                cornerRadius: 8)
                                .frame(width: geometry.size.width * lengthPercent - totalMargin, height: (geometry.size.width * lengthPercent - totalMargin) * CGFloat(viewModel.board.ranks) / CGFloat(viewModel.board.files))
                            Spacer()
                        }
                        
                    }
                    .listRowBackground(Color.backgroundColor)
                    .listRowInsets(EdgeInsets())
                    .disabled(true)
                    
                    Section(header: Text("Patterns")) {
                        ForEach(viewModel.patterns) { pattern in
                            patternView(pattern)
                                .listRowBackground(Color.rowColor)
                        }
                        
                        .onDelete { (patternIndex) in
                            moverManager.removePattern(at: patternIndex, movementType: viewModel.selectedMovementType)
                        }

                        
                        Button(action: {
                            self.isAddPatternViewShowing = true
                        }, label: {
                            // TODO: Refactor this + button interface
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("Add Pattern")
                            }
                            .foregroundColor(Color.blue)
                        })
                        .listRowBackground(Color.rowColor)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle(Text(viewModel.piece.name), displayMode: .inline)
            .sheet(isPresented: $isAddPatternViewShowing) {
                EditPatternView(
                    title: "Add Pattern",
                    pattern: Pattern(.horizontal),
                    piece: viewModel.piece,
                    isPresented: $isAddPatternViewShowing
                ) { pattern in
                    moverManager.addPattern(pattern, movementType: viewModel.selectedMovementType)
                }
            }
        }
    }
    
    func patternView(_ pattern: Pattern) -> some View {
        Text(pattern.string)
    }
    
    init(moverManager: MoverManager) {
        self._moverManager = StateObject(wrappedValue: moverManager)
        self.viewModel = PieceMovementEditorViewModel(moverManager: moverManager)
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.boardGreen)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor(.white)], for: .selected)
    }
}
