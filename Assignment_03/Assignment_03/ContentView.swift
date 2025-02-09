//
//  ContentView.swift
//  Assignment_03
//
//  Created by Surya Narreddi on 09/02/25.
//

/*
 
 INITIALIZE GAME COMPONENTS:
     - Set up game states (ball position, velocity, score, etc.)
     - Configure field dimensions and positions
     - Set up animation timers

 DEFINE GAME ELEMENTS:
     1. Field Elements:
         - Draw horizontal goal line
         - Draw penalty box
         - Draw D-arc (semi-circle)
         - Set opacity and line width

     2. Particle System (for confetti):
         - Initialize particle properties (position, angle, speed)
         - Create random colored circles
         - Animate particles in random directions
         - Define particle motion behavior

     3. Ball:
         - Create white circle with shadow
         - Add gesture recognition
         - Track position and velocity
         - Apply physics (friction, bouncing)

     4. Goal:
         - Create moving white rectangle
         - Define movement boundaries
         - Set movement speed and direction

     5. Power/Direction Indicators:
         - Create gradient power line (green to red)
         - Create direction arrow
         - Calculate lengths based on drag distance

 MAIN GAME LOOP:
     Every 1/60th second:
         1. Update goal position:
             - Move goal left/right
             - Reverse direction at boundaries

         2. If ball is moving:
             - Update ball position using velocity
             - Apply friction (0.99 multiplier)
             - Check for collisions:
                 IF hits side walls:
                     - Bounce with 0.8 elasticity
                     - Keep within bounds
                 
                 IF crosses goal line:
                     IF aligned with goal:
                         - Increment score
                         - Show confetti
                         - Reset ball position
                     ELSE:
                         - Wait 0.5 seconds
                         - Animate ball back to start
                 
                 IF ball stops (speed < 0.1):
                     - Set ball to stationary

 HANDLE USER INTERACTIONS:
     ON DRAG START:
         - Record drag start position
         - Show power and direction indicators

     ON DRAG END:
         - Calculate drag distance and direction
         - Normalize direction vector
         - Apply power (0.065 * distance)
         - Set ball in motion

 HELPER FUNCTIONS:
     1. Reset Ball:
         - Stop ball movement
         - Reset velocity to zero
         - Position at screen bottom center
         - Apply animation if needed

     2. Update Goal Position:
         - Move goal horizontally
         - Check screen boundaries
         - Reverse direction when needed

     3. Calculate Power:
         - Get distance from drag
         - Apply power multiplier
         - Normalize direction vector

     4. Draw Power Indicators:
         - Show gradient line behind ball
         - Show arrow in front of ball
         - Scale based on drag distance

 VISUAL EFFECTS:
     1. Ball Shadow:
         - Add drop shadow below
         - Add highlight overlay

     2. Confetti Effect:
         - Trigger on goal scored
         - Animate multiple colored particles
         - Fade out after 1 second
 
 */

import SwiftUI

// MARK: - Particle System
struct ParticleSystem: View {
    let count: Int
    let creationPoint: CGPoint
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<count, id: \.self) { _ in
                Circle()
                    .fill(Color.random)
                    .frame(width: 5, height: 5)
                    .modifier(ParticleMotionModifier(creationPoint: creationPoint))
            }
        }
    }
}

struct ParticleMotionModifier: ViewModifier {
    let creationPoint: CGPoint
    @State private var position: CGPoint
    @State private var angle = Double.random(in: 0...2 * .pi)
    @State private var speed = Double.random(in: 2...5)
    
    init(creationPoint: CGPoint) {
        self.creationPoint = creationPoint
        _position = State(initialValue: creationPoint)
    }
    
    func body(content: Content) -> some View {
        content
            .position(position)
            .onAppear {
                withAnimation(.linear(duration: 1.0)) {
                    position = CGPoint(
                        x: creationPoint.x + cos(angle) * speed * 50,
                        y: creationPoint.y + sin(angle) * speed * 50
                    )
                }
            }
    }
}

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

// MARK: - Field Elements
struct FieldElements: View {
    var body: some View {
        Path { path in
            // Horizontal line across the screen at goal height
            path.move(to: CGPoint(x: 0, y: 50))
            path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: 50))
            
            // Main penalty box
            path.addRect(CGRect(x: UIScreen.main.bounds.width/2 - 75, y: 50, width: 150, height: 100))
            
            // D arc
            path.addArc(center: CGPoint(x: UIScreen.main.bounds.width/2, y: 150),
                       radius: 50,
                       startAngle: .degrees(0),
                       endAngle: .degrees(180),
                       clockwise: false)
        }
        .stroke(Color.white.opacity(0.5), lineWidth: 2)
    }
}

// MARK: - Content View
struct ContentView: View {
    @State private var ballPosition = CGPoint(x: 200, y: 600)
    @State private var dragStartPosition: CGPoint?
    @State private var isDragging = false
    @State private var ballVelocity = CGVector.zero
    @State private var isMoving = false
    @State private var goalPosition = CGFloat(200)
    @State private var goalDirection = 1.0
    @State private var score = 0
    @State private var showConfetti = false
    @State private var isResetting = false  // Added flag to prevent multiple resets
    
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var powerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.green, .yellow, .red]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Rectangle()
                    .fill(Color(red: 0.1, green: 0.4, blue: 0.2))
                    .ignoresSafeArea()
                
                // Field lines
                FieldElements()
                
                // Moving goal
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 100, height: 10)
                    .position(x: goalPosition, y: 50)
                
                // Power indicator and direction arrow
                if isDragging, let start = dragStartPosition {
                    let dx = start.x - ballPosition.x
                    let dy = start.y - ballPosition.y
                    let distance = sqrt(dx * dx + dy * dy)
                    
                    // Power line (behind ball)
                    Path { path in
                        path.move(to: ballPosition)
                        path.addLine(to: start)
                    }
                    .stroke(powerGradient, lineWidth: 10)
                    
                    // Direction arrow (in front of ball)
                    let arrowLength = min(distance * 1.5, 100)
                    let normalizedDx = -dx / distance
                    let normalizedDy = -dy / distance
                    let arrowEnd = CGPoint(
                        x: ballPosition.x + normalizedDx * arrowLength,
                        y: ballPosition.y + normalizedDy * arrowLength
                    )
                    
                    Path { path in
                        // Main arrow line
                        path.move(to: ballPosition)
                        path.addLine(to: arrowEnd)
                        
                        // Arrow head
                        let angle = CGFloat.pi / 6
                        let arrowSize: CGFloat = 20
                        let theta = atan2(-dy, -dx)
                        
                        let point1 = CGPoint(
                            x: arrowEnd.x - arrowSize * cos(theta + angle),
                            y: arrowEnd.y - arrowSize * sin(theta + angle)
                        )
                        let point2 = CGPoint(
                            x: arrowEnd.x - arrowSize * cos(theta - angle),
                            y: arrowEnd.y - arrowSize * sin(theta - angle)
                        )
                        
                        path.move(to: arrowEnd)
                        path.addLine(to: point1)
                        path.move(to: arrowEnd)
                        path.addLine(to: point2)
                    }
                    .stroke(Color.white, lineWidth: 3)
                }
                
                // Ball
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 5)  // Drop shadow
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)  // Inner highlight
                            .blur(radius: 1)
                    )
                    .position(ballPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isMoving {
                                    dragStartPosition = value.location
                                    isDragging = true
                                }
                            }
                            .onEnded { value in
                                if !isMoving {
                                    isDragging = false
                                    if let start = dragStartPosition {
                                        // Calculate direction from ball to drag point
                                        let dx = start.x - ballPosition.x
                                        let dy = start.y - ballPosition.y
                                        let distance = sqrt(dx * dx + dy * dy)
                                        
                                        // Normalize and invert direction (to make ball go opposite way)
                                        let normalizedDx = -dx / distance
                                        let normalizedDy = -dy / distance
                                        
                                        // Apply power to normalized direction
                                        let power = distance * 0.065
                                        ballVelocity = CGVector(
                                            dx: normalizedDx * power,
                                            dy: normalizedDy * power
                                        )
                                        isMoving = true
                                    }
                                    dragStartPosition = nil
                                }
                            }
                    )
                
                // Score
                Text("Score: \(score)")
                    .foregroundColor(.white)
                    .font(.title)
                    .position(x: geometry.size.width - 100, y: 30)
                
                if showConfetti {
                    ParticleSystem(count: 50, creationPoint: CGPoint(x: goalPosition, y: 50))
                }
            }
            .onReceive(timer) { _ in
                updateGame()
            }
        }
    }
    
    private func updateGame() {
        updateGoalPosition()
        
        if isMoving {
            // Update position
            ballPosition.x += ballVelocity.dx
            ballPosition.y += ballVelocity.dy
            
            // Check for goal
            if ballPosition.y < 60 && abs(ballPosition.x - goalPosition) < 50 {
                score += 1
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showConfetti = false
                }
                resetBall()
            }
            
            // Wall bouncing
            let bounds = UIScreen.main.bounds
            if ballPosition.x < 20 || ballPosition.x > bounds.width - 20 {
                ballVelocity.dx *= -0.8
                ballPosition.x = max(20, min(bounds.width - 20, ballPosition.x))
            }
            
            // Check if ball crosses goal line without scoring
            if (ballPosition.y < 50 && abs(ballPosition.x - goalPosition) > 50 && !isResetting) {
                isResetting = true  // Prevent multiple resets
                // Let the ball continue moving for 0.5 seconds after crossing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        resetBall()
                    }
                }
            } else if ballPosition.y < -50 || ballPosition.y > bounds.height + 50 {
                // Instant reset when going way off screen
                resetBall()
            }
            
            // Apply friction
            ballVelocity.dx *= 0.99
            ballVelocity.dy *= 0.99
            
            // Check if ball stopped
            let speed = sqrt(ballVelocity.dx * ballVelocity.dx + ballVelocity.dy * ballVelocity.dy)
            if speed < 0.1 {
                isMoving = false
            }
        }
    }
    
    private func updateGoalPosition() {
        let bounds = UIScreen.main.bounds
        goalPosition += goalDirection * 3
        if goalPosition < 50 || goalPosition > bounds.width - 50 {
            goalDirection *= -1
        }
    }
    
    private func resetBall() {
        let bounds = UIScreen.main.bounds
        // Reset ball velocity first
        ballVelocity = .zero
        isMoving = false
        isResetting = false  // Reset the flag
        
        // Set new position with animation support
        ballPosition = CGPoint(x: bounds.width/2, y: bounds.height * 0.6)
    }
}

// MARK: - Extensions
extension CGVector {
    static var zero: CGVector {
        CGVector(dx: 0, dy: 0)
    }
}

#Preview {
    ContentView()
}
