import SwiftUI

// MARK: - Snapshot Reel Player View (Wrapper for ReelVideoPlayer)

struct SnapshotReelPlayerView: View {
    let videoName: String
    @Binding var isPresented: Bool
    @State private var is2xSpeed = false
    @StateObject private var tabBarHelper = FDSTabBarHelper()
    
    var body: some View {
        ZStack {
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
                bottomInset: 0,
                is2xSpeed: $is2xSpeed
            )
            .environmentObject(tabBarHelper)
            
            // Back Button Overlay (Top Left)
            VStack {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
