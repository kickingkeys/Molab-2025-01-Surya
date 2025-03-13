import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var cameraHandler = CameraHandler()
    
    var body: some View {
        ZStack {
            // Camera preview with LEGO effect
            if let image = cameraHandler.legoImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            
            // Controls overlay
            VStack {
                Spacer()
                
                HStack {
                    // Size adjustment buttons
                    VStack {
                        Button(action: {
                            cameraHandler.increaseLegoSize()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        
                        Text("Brick Size: \(cameraHandler.legoSize)")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(.vertical, 5)
                        
                        Button(action: {
                            cameraHandler.decreaseLegoSize()
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    // Camera controls
                    HStack(spacing: 20) {
                        // Photo capture button
                        Button(action: {
                            cameraHandler.takePhoto()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "camera")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        // Record button
                        Button(action: {
                            if cameraHandler.isRecording {
                                cameraHandler.stopRecording()
                            } else {
                                cameraHandler.startRecording()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(cameraHandler.isRecording ? Color.red : Color.white)
                                    .frame(width: 70, height: 70)
                                
                                if cameraHandler.isRecording {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white)
                                        .frame(width: 20, height: 20)
                                } else {
                                    Circle()
                                        .stroke(Color.red, lineWidth: 4)
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Photo library access (placeholder)
                    Button(action: {
                        // This would open the photo library in a complete app
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
        }
        .statusBar(hidden: true)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
