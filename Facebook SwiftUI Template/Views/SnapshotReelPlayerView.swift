import SwiftUI
import AVKit
import AVFoundation

// MARK: - Snapshot Reel Player View (Exact ReelsTabView Structure)
// This is the EXACT structure from ReelsTabView.swift in facebook-template-v0.4
// Modified only to show a single reel and include a back button

struct SnapshotReelPlayerView: View {
    let videoName: String
    @Binding var isPresented: Bool
    @State private var currentReelIndex: Int? = 0
    @State private var is2xSpeed = false
    @StateObject private var tabBarHelper = FDSTabBarHelper()
    
    // Create the single reel to display
    private var snapshotReel: FacebookReel {
        FacebookReel(
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
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ReelVideoPlayer(
                                reel: snapshotReel,
                                reelIndex: 0,
                                isCurrentReel: currentReelIndex == 0,
                                bottomInset: 80,
                                is2xSpeed: $is2xSpeed
                            )
                            .containerRelativeFrame([.horizontal, .vertical])
                            .clipped()
                            .id(0)
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: $currentReelIndex)
                    .background(Color("alwaysBlack"))
                    .statusBarHidden(false)
                    .ignoresSafeArea(.all, edges: .vertical)
                    
                    // Top navigation bar (exact from ReelsTabView)
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(height: geometry.safeAreaInsets.top)
                            
                            HStack(alignment: .center, spacing: 12) {
                                // Back button (replaces "For you/Explore" navigation)
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
                            .animation(.swapShuffleIn(MotionDuration.shortIn), value: is2xSpeed)
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
                            .animation(.swapShuffleIn(MotionDuration.shortIn), value: is2xSpeed)
                        )
                        Spacer()
                    }
                    .ignoresSafeArea(.all, edges: .top)
                }
            }
            .onAppear {
                tabBarHelper.currentReelIndex = currentReelIndex
            }
        }
        .environmentObject(tabBarHelper)
    }
}
