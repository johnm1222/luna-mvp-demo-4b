import SwiftUI
import AVKit
import AVFoundation

// MARK: - Snapshot Reel Player View (Full ReelsTabView-style Experience)

struct SnapshotReelPlayerView: View {
    let videoName: String
    @Binding var isPresented: Bool
    @State private var is2xSpeed = false
    @StateObject private var tabBarHelper = FDSTabBarHelper()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color("alwaysBlack")
                    .ignoresSafeArea()
                
                // Create a dummy reel for the video player using the passed videoName
                let dummyReel = FacebookReel(
                    id: "snapshot",
                    username: "Becker Threads",
                    profileImage: "pantone_1",
                    caption: "Cloud Dancer by Pantone - the 2026 Color of the Year 🎨",
                    timeAgo: "now",
                    likes: 342,
                    comments: 127,
                    shares: 42,
                    videoFileName: videoName,
                    verified: false
                )
                
                // Use the existing ReelVideoPlayer from ReelsTabView.swift
                ReelVideoPlayer(
                    reel: dummyReel,
                    reelIndex: 0,
                    isCurrentReel: true,
                    bottomInset: 80,
                    is2xSpeed: $is2xSpeed
                )
                .containerRelativeFrame([.horizontal, .vertical])
                .clipped()
                .environmentObject(tabBarHelper)
                
                // Top Navigation Overlay (ReelsTabView style)
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: geometry.safeAreaInsets.top)
                        
                        HStack(alignment: .center, spacing: 12) {
                            // Back button
                            Button(action: {
                                isPresented = false
                            }) {
                                Image("chevron-left-filled")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color("primaryIconOnMedia"))
                            }
                            .padding(.leading, 12)
                            
                            Spacer()
                        }
                        .frame(height: 52)
                        .opacity(is2xSpeed ? 0 : 1)
                    }
                    .background(
                        LinearGradient(
                            stops: [
                                .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                                .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.3),
                                .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.7),
                                .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 180)
                        .opacity(is2xSpeed ? 0 : 1)
                    )
                    Spacer()
                }
                .ignoresSafeArea(.all, edges: .top)
            }
        }
        .statusBarHidden(false)
        .ignoresSafeArea(.all, edges: .vertical)
    }
}
