import SwiftUI

// MARK: - Snapshot Permalink View

struct SnapshotPermalinkView: View {
    let post: SnapshotPostData
    let snapshotItem: SnapshotItem
    @Environment(\.dismiss) private var dismiss
    @State private var isLiked = false
    @State private var commentText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            navigationBar
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Post content
                        postContent
                            .frame(width: geometry.size.width)
                        
                        // UFI buttons
                        ufiButtons
                            .frame(width: geometry.size.width)
                        
                        // Bling bar (reactions summary)
                        blingBar
                            .frame(width: geometry.size.width)
                        
                        // Meta AI card
                        metaAICard
                            .frame(width: geometry.size.width)
                        
                        // Comments section
                        commentsSection
                            .frame(width: geometry.size.width)
                    }
                }
                .background(Color("surfaceBackground"))
            }
            
            // Comment composer
            commentComposer
        }
        .hideFDSTabBar(true)
    }
    
    // MARK: - Navigation Bar
    
    private var navigationBar: some View {
        FDSNavigationBarCentered(
            title: post.authorName,
            backAction: { dismiss() },
            icon1: { FDSIconButton(icon: "magnifying-glass-outline", action: {}) },
            icon2: { FDSIconButton(icon: "share-outline", action: {}) }
        )
    }
    
    // MARK: - Post Content
    
    private var postContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Author header
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
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            // Post text
            if let text = post.text {
                Text(text)
                    .body2Typography()
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
        }
    }
    
    // MARK: - UFI Buttons
    
    private var ufiButtons: some View {
        HStack(spacing: 0) {
            // Like
            Button(action: {
                withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                    isLiked.toggle()
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
            
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, 4)
    }
    
    // MARK: - Bling Bar
    
    private var blingBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                // Reactions
                HStack(spacing: -4) {
                    ForEach(post.reactions, id: \.self) { reaction in
                        Image(reaction)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                
                Text("\(post.likeCount)")
                    .meta3Typography()
                    .foregroundStyle(Color("secondaryText"))
                
                Spacer()
                
                Text("\(post.commentCount) comments")
                    .meta3Typography()
                    .foregroundStyle(Color("secondaryText"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
        }
    }
    
    // MARK: - Meta AI Card
    
    private var metaAICard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image("fb-meta-ai-assistant")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Meta AI")
                        .headline4EmphasizedTypography()
                        .foregroundStyle(Color("primaryText"))
                    
                    Text("Ask follow-up questions about this post")
                        .meta3Typography()
                        .foregroundStyle(Color("secondaryText"))
                }
                
                Spacer()
            }
            
            // Sample questions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(sampleQuestions, id: \.self) { question in
                        Text(question)
                            .body4Typography()
                            .foregroundStyle(Color("primaryText"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color("cardBackground"))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("borderUiEmphasis"), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(12)
        .background(Color("bottomSheetBackgroundDeemphasized"))
    }
    
    // MARK: - Comments Section
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Most relevant")
                .headline4EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            ForEach(sampleComments) { comment in
                CommentRow(comment: comment)
            }
        }
    }
    
    // MARK: - Comment Composer
    
    private var commentComposer: some View {
        HStack(spacing: 12) {
            Image("profile1")
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            TextField("Write a comment...", text: $commentText)
                .body3Typography()
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color("cardBackground"))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("borderUiEmphasis"), lineWidth: 1)
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color("surfaceBackground"))
    }
    
    // MARK: - Sample Data
    
    private var sampleQuestions: [String] {
        [
            "What colors are trending?",
            "How to achieve this look?",
            "Budget-friendly options?"
        ]
    }
    
    private var sampleComments: [CommentData] {
        [
            CommentData(
                authorName: "Sarah Miller",
                profileImage: "profile2",
                text: "Love the warm tones! This is exactly what I've been looking for.",
                timeAgo: "2h",
                likes: 24
            ),
            CommentData(
                authorName: "James Wilson",
                profileImage: "profile3",
                text: "Great tips! Already started implementing some of these ideas.",
                timeAgo: "4h",
                likes: 12
            )
        ]
    }
}

// MARK: - Comment Data

private struct CommentData: Identifiable {
    let id = UUID()
    let authorName: String
    let profileImage: String
    let text: String
    let timeAgo: String
    let likes: Int
}

// MARK: - Comment Row

private struct CommentRow: View {
    let comment: CommentData
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(comment.profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(comment.authorName)
                        .headline4EmphasizedTypography()
                        .foregroundStyle(Color("primaryText"))
                    
                    Text(comment.text)
                        .body3Typography()
                        .foregroundStyle(Color("primaryText"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color("cardBackground"))
                .cornerRadius(12)
                
                HStack(spacing: 16) {
                    Text(comment.timeAgo)
                        .meta3Typography()
                        .foregroundStyle(Color("secondaryText"))
                    
                    Button(action: {}) {
                        Text("Like")
                            .meta3LinkTypography()
                            .foregroundStyle(Color("secondaryText"))
                    }
                    
                    Button(action: {}) {
                        Text("Reply")
                            .meta3LinkTypography()
                            .foregroundStyle(Color("secondaryText"))
                    }
                    
                    if comment.likes > 0 {
                        HStack(spacing: 4) {
                            Image("like")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            
                            Text("\(comment.likes)")
                                .meta3Typography()
                                .foregroundStyle(Color("secondaryText"))
                        }
                    }
                }
                .padding(.leading, 12)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SnapshotPermalinkView(
            post: SnapshotPostData(
                authorName: "Architecture Digest",
                profileImage: "profileAD",
                isVerified: true,
                timeAgo: "3h",
                text: "As we look ahead to 2026, interior design is embracing warm neutrals and earthy accents. Think soft beiges, warm taupes, and muted greens that create a cozy atmosphere.",
                imageName: "interior1",
                likeCount: "442",
                commentCount: "155",
                shareCount: "99.9K",
                reactions: ["like", "love", "wow"]
            ),
            snapshotItem: SnapshotItem(
                emoji: "🛋️",
                headline: "Homes are leaning into \"soft minimalism\"",
                meta: "Read the latest interior design trends",
                detailTitle: "2026 Interior Design Trends",
                summaryParagraph: "",
                relatedPosts: [],
                profileImage: "profileAD",
                mediaItems: []
            )
        )
    }
    .environmentObject(FDSTabBarHelper())
}

