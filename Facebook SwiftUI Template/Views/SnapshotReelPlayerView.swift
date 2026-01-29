import SwiftUI
import AVKit
import AVFoundation

// MARK: - Snapshot Reel Player View (Exact ReelsTabView Structure)
// This is the EXACT structure from ReelsTabView.swift in facebook-template-v0.4
// Modified to show multiple snapshot reels and include a back button

struct SnapshotReelPlayerView: View {
    let videoName: String
    @Binding var isPresented: Bool
    @State private var currentReelIndex: Int? = 0
    @State private var is2xSpeed = false
    @StateObject private var tabBarHelper = FDSTabBarHelper()
    @State private var shuffledReels: [FacebookReel] = []
    
    // Create multiple snapshot reels to swipe through
    private var snapshotReels: [FacebookReel] {
        [
            FacebookReel(
                id: "snapshot1",
                username: "Becker Threads",
                profileImage: "pantone_1",
                caption: "Cloud Dancer by Pantone - the 2026 Color of the Year 🎨",
                timeAgo: "now",
                likes: 342,
                comments: 127,
                shares: 42,
                videoFileName: "dance",
                verified: false
            ),
            FacebookReel(
                id: "snapshot2",
                username: "Denver Nuggets",
                profileImage: "nba_1",
                caption: "Jokic continues to dominate the MVP race 🏀",
                timeAgo: "2h",
                likes: 1240,
                comments: 256,
                shares: 89,
                videoFileName: "surf",
                verified: true
            ),
            FacebookReel(
                id: "snapshot3",
                username: "Children's Museum",
                profileImage: "winter1",
                caption: "Winter programs now open for registration ❄️",
                timeAgo: "4h",
                likes: 567,
                comments: 89,
                shares: 34,
                videoFileName: "dancing",
                verified: false
            ),
            FacebookReel(
                id: "snapshot4",
                username: "Healthy Kids",
                profileImage: "ffmeal_1",
                caption: "High protein toddler snacks for busy parents 🥣",
                timeAgo: "6h",
                likes: 892,
                comments: 145,
                shares: 67,
                videoFileName: "handsin",
                verified: false
            ),
            FacebookReel(
                id: "snapshot5",
                username: "Denver Eats",
                profileImage: "denver1",
                caption: "Restaurant Week is here! Check out these amazing spots 🍣",
                timeAgo: "8h",
                likes: 1456,
                comments: 234,
                shares: 123,
                videoFileName: "ocean",
                verified: true
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<shuffledReels.count, id: \.self) { index in
                                ReelVideoPlayer(
                                    reel: shuffledReels[index],
                                    reelIndex: index,
                                    isCurrentReel: currentReelIndex == index,
                                    bottomInset: 80,
                                    is2xSpeed: $is2xSpeed
                                )
                                .containerRelativeFrame([.horizontal, .vertical])
                                .clipped()
                                .id(index)
                            }
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
            .onChange(of: currentReelIndex) { _, newIndex in
                tabBarHelper.currentReelIndex = newIndex
            }
            .onAppear {
                // Shuffle reels randomly each time the player appears
                shuffledReels = snapshotReels.shuffled()
                currentReelIndex = 0
                tabBarHelper.currentReelIndex = currentReelIndex
            }
        }
        .environmentObject(tabBarHelper)
    }
}
