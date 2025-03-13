//
//  CDCollectionView.swift
//  Assignment_04CD search
//
//  Created by Surya Narreddi on 24/02/25.
//

import SwiftUI

struct CDCollectionView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Background grid
            GridBackground()
            
            // CD Collection
            ForEach(0..<5, id: \.self) { index in
                CDView(index: index)
                    .position(appState.cdPositions[index])
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                appState.cdPositions[index] = value.location
                            }
                    )
                    .overlay(
                        appState.currentlyPlayingIndex == index ?
                            RoundedRectangle(cornerRadius: 75)
                                .stroke(Color.orange, lineWidth: 3)
                                .frame(width: 150, height: 150)
                        : nil
                    )
            }
            
            // Drawing mode toggle
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        appState.isDrawMode.toggle()
                    }) {
                        Image(systemName: appState.isDrawMode ? "pencil" : "eraser")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
}

// Grid background
struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Vertical lines
                for i in stride(from: 0, to: width, by: 30) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i, y: height))
                }
                
                // Horizontal lines
                for i in stride(from: 0, to: height, by: 30) {
                    path.move(to: CGPoint(x: 0, y: i))
                    path.addLine(to: CGPoint(x: width, y: i))
                }
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
        .background(Color.white)
    }
}
