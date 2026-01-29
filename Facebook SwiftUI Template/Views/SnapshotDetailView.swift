import SwiftUI

// MARK: - Snapshot Detail View

struct SnapshotDetailView: View {
    let item: SnapshotItem
    @Environment(\.dismiss) private var dismiss
    
    private var firstPost: SnapshotPostData? {
        item.relatedPosts.first
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar with back button only
            FDSNavigationBarCentered(
                backAction: { dismiss() }
            )
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 4) {
                        // Header unit
                        SnapshotHeaderUnit(
                            title: item.detailTitle,
                            summaryParagraph: item.summaryParagraph,
                            firstPost: firstPost,
                            item: item
                        )
                        .frame(width: geometry.size.width)
                        
                        // Feed posts
                        ForEach(Array(item.relatedPosts.enumerated()), id: \.element.id) { index, post in
                            if index == 0 {
                                // First post navigates to permalink
                                NavigationLink {
                                    SnapshotPermalinkView(post: post, snapshotItem: item)
                                } label: {
                                    SnapshotFeedPost(post: post, isInteractive: false)
                                        .frame(width: geometry.size.width)
                                }
                                .buttonStyle(FDSPressedState(cornerRadius: 0))
                            } else {
                                SnapshotFeedPost(post: post, isInteractive: true)
                                    .frame(width: geometry.size.width)
                            }
                        }
                    }
                }
                .background(Color("wash"))
            }
        }
        .hideFDSTabBar(true)
    }
}

// MARK: - Snapshot Header Unit

private struct SnapshotHeaderUnit: View {
    let title: String
    let summaryParagraph: String
    let firstPost: SnapshotPostData?
    let item: SnapshotItem
    
    private var summaryText: String {
        // Return the paragraph directly
        summaryParagraph
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Emoji + Title with menu button
            HStack(alignment: .top, spacing: 8) {
                Text("\(item.emoji) \(title)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {}) {
                    Image("dots-3-horizontal-filled")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color("primaryIcon"))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(FDSPressedState(
                    circle: true,
                    padding: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                ))
            }
            .padding(.horizontal, 12)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Summary paragraph
            Text(summaryText)
                .body3Typography()
                .foregroundStyle(Color("primaryText"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            
            // Sources action chip
            FDSActionChip(
                size: .medium,
                label: "Sources",
                action: {}
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 20)
            
            // "More about this" headline
            Text("More about this")
                .headline4Typography()
                .foregroundStyle(Color("primaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            
            // Horizontal scroll with variable width media
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(item.relatedPosts.enumerated()), id: \.element.id) { index, post in
                        if let imageName = post.imageName {
                            MediaCard(
                                imageName: imageName,
                                aspectRatio: getAspectRatio(for: index)
                            )
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 16)
            
            // Thumbs up/down
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image("hand-thumbs-up-outline")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color("primaryIcon"))
                }
                .buttonStyle(FDSPressedState(scale: .medium))
                
                Button(action: {}) {
                    Image("hand-thumbs-down-outline")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color("primaryIcon"))
                }
                .buttonStyle(FDSPressedState(scale: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(Color("surfaceBackground"))
    }
    
    private func getAspectRatio(for index: Int) -> MediaAspectRatio {
        // Cycle through: 9:16, 16:9, 1:1
        let ratios: [MediaAspectRatio] = [.portrait, .landscape, .square]
        return ratios[index % ratios.count]
    }
}

// MARK: - Media Card

private struct MediaCard: View {
    let imageName: String
    let aspectRatio: MediaAspectRatio
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image with enforced aspect ratio and crop
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: aspectRatio.width, height: aspectRatio.height)
                .clipped()
            
            // Media type icon based on aspect ratio
            Circle()
                .fill(Color.black.opacity(0.6))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(Color.white)
                )
                .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var iconName: String {
        switch aspectRatio {
        case .landscape:
            return "camera-filled"  // Photo icon for horizontal images
        case .portrait:
            return "video-filled"   // Cinema slate icon for vertical videos
        case .square:
            return "camera-filled"  // Photo icon for square
        }
    }
}

// MARK: - Snapshot Feed Post

struct SnapshotFeedPost: View {
    let post: SnapshotPostData
    let isInteractive: Bool
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Post header
            HStack(spacing: 12) {
                Image(post.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color("mediaInnerBorder"), lineWidth: 0.5)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.authorName)
                            .headline4EmphasizedTypography()
                            .foregroundStyle(Color("primaryText"))
                        
                        if post.isVerified {
                            Image("badge-checkmark-filled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(Color("accentColor"))
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(post.timeAgo)
                            .meta4Typography()
                            .foregroundStyle(Color("secondaryText"))
                        
                        Text("·")
                            .meta4Typography()
                            .foregroundStyle(Color("secondaryText"))
                        
                        Image("globe-americas-filled")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color("secondaryIcon"))
                    }
                }
                
                Spacer()
                
                FDSIconButton(icon: "dots-3-horizontal-filled", size: .size20, action: {})
                FDSIconButton(icon: "cross-filled", size: .size20, action: {})
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            // Post text
            if let text = post.text {
                Text(text)
                    .body3Typography()
                    .foregroundStyle(Color("primaryText"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
            
            // Post image
            if let imageName = post.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            
            // UFI (Like, Comment, Share)
            HStack(spacing: 0) {
                // Like
                Button(action: {
                    if isInteractive {
                        withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                            isLiked.toggle()
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(isLiked ? "like-filled-20" : "like-outline-20")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(isLiked ? Color("reactionLike") : Color("secondaryIcon"))
                        
                        Text(post.likeCount)
                            .body4LinkTypography()
                            .foregroundStyle(isLiked ? Color("reactionLike") : Color("secondaryText"))
                            .contentTransition(.numericText())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(FDSPressedState(cornerRadius: 8))
                .disabled(!isInteractive)
                
                // Comment
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image("comment-outline")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color("secondaryIcon"))
                        
                        Text(post.commentCount)
                            .body4LinkTypography()
                            .foregroundStyle(Color("secondaryText"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(FDSPressedState(cornerRadius: 8))
                .disabled(!isInteractive)
                
                // Share
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image("share-outline")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color("secondaryIcon"))
                        
                        Text(post.shareCount)
                            .body4LinkTypography()
                            .foregroundStyle(Color("secondaryText"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(FDSPressedState(cornerRadius: 8))
                .disabled(!isInteractive)
                
                Spacer()
                
                // Inline reactions
                HStack(spacing: -4) {
                    ForEach(post.reactions, id: \.self) { reaction in
                        Image(reaction)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .frame(height: 44)
        }
        .frame(maxWidth: .infinity)
        .background(Color("surfaceBackground"))
        .clipped()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SnapshotDetailView(item: SnapshotItem(
            emoji: "🛋️",
            headline: "Homes are leaning into \"soft minimalism\"",
            meta: "Read the latest interior design trends",
            detailTitle: "2026 Interior Design Trends",
            summaryParagraph: "Discover why warm neutral and earthy accents are replacing cool grays. Embrace the sophisticated grandma core aesthetic featuring layered patterns. See why walnut finishes are in while 2010s fads are officially out.",
            relatedPosts: [
                SnapshotPostData(
                    authorName: "Architecture Digest",
                    profileImage: "profileAD",
                    isVerified: true,
                    timeAgo: "3h",
                    text: "As we look ahead to 2026, interior design is embracing warm neutrals and earthy accents.",
                    imageName: "interior1",
                    likeCount: "442",
                    commentCount: "155",
                    shareCount: "99.9K",
                    reactions: ["like", "love", "wow"]
                ),
                SnapshotPostData(
                    authorName: "Julie Jones",
                    profileImage: "profile3",
                    isVerified: true,
                    timeAgo: "1w",
                    text: "I'm excited to break down interior design trends for 2026 including...",
                    imageName: "interior2",
                    likeCount: "442",
                    commentCount: "155",
                    shareCount: "99.9K",
                    reactions: ["like", "love", "wow"]
                ),
                SnapshotPostData(
                    authorName: "Architecture Digest",
                    profileImage: "profileAD",
                    isVerified: true,
                    timeAgo: "3h",
                    text: nil,
                    imageName: "interior3",
                    likeCount: "442",
                    commentCount: "155",
                    shareCount: "99.9K",
                    reactions: ["like", "love"]
                )
            ],
            profileImage: "profileAD",
            mediaItems: []
        ))
    }
    .environmentObject(FDSTabBarHelper())
}


