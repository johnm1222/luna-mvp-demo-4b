import SwiftUI

// MARK: - Comment Type Enumeration
enum FDSCommentType {
    case topLevel
    case reply
    
    var profilePhotoSize: CGFloat {
        switch self {
        case .topLevel: return 40
        case .reply: return 24
        }
    }
    
    var leadingInset: CGFloat {
        switch self {
        case .topLevel: return 0
        case .reply: return 52 // 40dp + 12dp spacing
        }
    }
}

// MARK: - Comment Pager Component
struct FDSCommentPager: View {
    let replyCount: Int
    @Binding var isExpanded: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.moveIn(MotionDuration.shortIn)) {
                isExpanded.toggle()
            }
        }) {
            HStack(alignment: .center, spacing: 8) {
                Image(isExpanded ? "chevron-up-outline" : "chevron-down-outline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color("secondaryIcon"))
                
                Text(isExpanded ? "Hide replies" : "View \(replyCount) \(replyCount == 1 ? "reply" : "replies")")
                    .body4LinkTypography()
                    .foregroundStyle(Color("secondaryText"))
            }
            .padding(.leading, 64) // Match reply inset (40dp profile + 12dp spacing)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(FDSPressedState(cornerRadius: 0, scale: .none))
    }
}

// MARK: - FDSComment Component
struct FDSComment: View {
    // MARK: - Properties
    let type: FDSCommentType
    let profileImage: String
    let actorName: String
    let timestamp: String
    let commentText: String
    let image: String?
    let onReplyTap: (() -> Void)?
    let onLikeTap: (() -> Void)?
    
    @State private var isExpanded: Bool = false
    @State private var reactions: [String]
    @State private var reactionCount: Int
    @State private var isLiked: Bool = false
    
    // MARK: - Initializer
    init(
        type: FDSCommentType = .topLevel,
        profileImage: String,
        actorName: String,
        timestamp: String,
        commentText: String,
        image: String? = nil,
        reactions: [String]? = nil,
        reactionCount: Int? = nil,
        onReplyTap: (() -> Void)? = nil,
        onLikeTap: (() -> Void)? = nil
    ) {
        self.type = type
        self.profileImage = profileImage
        self.actorName = actorName
        self.timestamp = timestamp
        self.commentText = commentText
        self.image = image
        self.onReplyTap = onReplyTap
        self.onLikeTap = onLikeTap
        
        // Initialize state
        self._reactions = State(initialValue: reactions ?? [])
        self._reactionCount = State(initialValue: reactionCount ?? 0)
    }
    
    private func handleLike() {
        withAnimation(.moveIn(MotionDuration.shortIn)) {
            if isLiked {
                // Unlike
                reactionCount = max(0, reactionCount - 1)
                isLiked = false
            } else {
                // Like
                reactionCount += 1
                isLiked = true
                
                // Add like reaction if not already present
                if !reactions.contains("like") {
                    reactions.insert("like", at: 0)
                }
            }
        }
        
        onLikeTap?()
    }
    
    // MARK: - Body
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile photo
            Image(profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: type.profilePhotoSize, height: type.profilePhotoSize)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(Color("mediaInnerBorder"), lineWidth: 0.5)
                )
            
            VStack(alignment: .leading, spacing: 0) {
                // Header: actor name + timestamp
                HStack(spacing: 0) {
                    Text(actorName)
                        .body4LinkTypography()
                        .foregroundStyle(Color("primaryText"))
                    
                    Text(" · ")
                        .body4Typography()
                        .foregroundStyle(Color("secondaryText"))
                    
                    Text(timestamp)
                        .body4Typography()
                        .foregroundStyle(Color("secondaryText"))
                }
                .padding(.top, 4)
                .padding(.bottom, 10)
                
                // Comment text with tap to expand
                Text(commentText)
                    .body3Typography()
                    .foregroundStyle(Color("primaryText"))
                    .lineLimit(isExpanded ? nil : 3)
                    .truncationMode(.tail)
                    .animation(.moveIn(MotionDuration.shortIn), value: isExpanded)
                    .onTapGesture {
                        isExpanded.toggle()
                    }
                
                // Image attachment (if present)
                if let image = image {
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 220, maxHeight: 220)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color("mediaInnerBorder"), lineWidth: 0.5)
                        )
                        .padding(.top, 12)
                }
                
                // Footer: Reply button + Inline reactions + Like icon button
                HStack {
                    HStack(spacing: 16) {
                        if let onReplyTap = onReplyTap {
                            Button(action: onReplyTap) {
                                Text("Reply")
                                    .body4LinkTypography()
                                    .foregroundStyle(Color("secondaryText"))
                            }
                            .buttonStyle(FDSPressedState(cornerRadius: 6, scale: .none, padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)))
                            
                        }
                        
                        if !reactions.isEmpty && reactionCount > 0 {
                            HStack(spacing: 4) {
                                InlineReactions(reactions: reactions)
                                
                                Text("\(reactionCount)")
                                    .body4Typography()
                                    .foregroundStyle(Color("secondaryText"))
                                    .contentTransition(.numericText())
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if onLikeTap != nil {
                        FDSIconButton(
                            icon: isLiked ? "like-filled" : "like-outline",
                            size: .size20,
                            color: isLiked ? .accent : .secondary,
                            action: handleLike
                        )
                    }
                }
                .padding(.top, 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, type.leadingInset + 12)
        .padding(.trailing, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Comment Card Component
struct CommentCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .meta4LinkTypography()
                .foregroundStyle(Color("primaryText"))
                .padding(12)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("cardBackground"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Thread With Pager Helper View
struct ThreadWithPager: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            FDSCommentPager(replyCount: 4, isExpanded: $isExpanded)
            
            if isExpanded {
                FDSComment(
                    type: .reply,
                    profileImage: "profile5",
                    actorName: "James Lee",
                    timestamp: "2h",
                    commentText: "This looks like it might be Waimea Bay!",
                    reactions: ["wow"],
                    reactionCount: 5,
                    onReplyTap: {
                        print("Reply tapped")
                    },
                    onLikeTap: {
                        print("Like tapped")
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                    removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                ))
                
                FDSComment(
                    type: .reply,
                    profileImage: "profile6",
                    actorName: "Olivia Martinez",
                    timestamp: "1h",
                    commentText: "Yes, I was there last summer. It's absolutely stunning in person!",
                    reactions: ["like"],
                    reactionCount: 15,
                    onReplyTap: {
                        print("Reply tapped")
                    },
                    onLikeTap: {
                        print("Like tapped")
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                    removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                ))
                
                FDSComment(
                    type: .reply,
                    profileImage: "profile16",
                    actorName: "Marcus Brown",
                    timestamp: "45m",
                    commentText: "I've been wanting to visit there for years!",
                    reactions: ["support"],
                    reactionCount: 3,
                    onReplyTap: {
                        print("Reply tapped")
                    },
                    onLikeTap: {
                        print("Like tapped")
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                    removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                ))
                
                FDSComment(
                    type: .reply,
                    profileImage: "profile12",
                    actorName: "Jessica Wu",
                    timestamp: "30m",
                    commentText: "The water looks so clear!",
                    image: "ocean",
                    reactions: ["love", "wow"],
                    reactionCount: 18,
                    onReplyTap: {
                        print("Reply tapped")
                    },
                    onLikeTap: {
                        print("Like tapped")
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                    removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                ))
            }
        }
    }
}

// MARK: - Comments Preview View
struct CommentsPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSComment",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    CommentCard(title: "Top-level comment") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .topLevel,
                                profileImage: "profile1",
                                actorName: "Sarah Johnson",
                                timestamp: "2h",
                                commentText: "This is amazing! I love how you captured the moment.",
                                reactions: ["love"],
                                reactionCount: 24,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                        }
                    }
                    
                    CommentCard(title: "Reply comment") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .reply,
                                profileImage: "profile2",
                                actorName: "Mike Chen",
                                timestamp: "1h",
                                commentText: "Thanks! It was such a beautiful day.",
                                reactions: ["like"],
                                reactionCount: 12,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                        }
                    }
                    
                    CommentCard(title: "Comment with long text (tap to expand)") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .topLevel,
                                profileImage: "profile3",
                                actorName: "Alex Rivera",
                                timestamp: "5h",
                                commentText: "I've been thinking about this for a while now, and I just wanted to share my thoughts with everyone. This is truly an incredible piece of work that deserves so much recognition. The attention to detail is remarkable, and I can see how much effort went into creating this. Keep up the amazing work!",
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                        }
                    }
                    
                    CommentCard(title: "Thread with pager (tap to expand/collapse)") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .topLevel,
                                profileImage: "profile4",
                                actorName: "Emma Wilson",
                                timestamp: "3h",
                                commentText: "Does anyone know where this was taken?",
                                reactions: ["like"],
                                reactionCount: 8,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                            
                            ThreadWithPager()
                        }
                    }
                    
                    CommentCard(title: "Conversation thread") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .topLevel,
                                profileImage: "profile15",
                                actorName: "Rachel Green",
                                timestamp: "4h",
                                commentText: "Amazing colors in this shot!",
                                reactions: ["love", "wow"],
                                reactionCount: 28,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile5",
                                actorName: "James Lee",
                                timestamp: "2h",
                                commentText: "This looks like it might be Waimea Bay!",
                                reactions: ["wow"],
                                reactionCount: 5,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile6",
                                actorName: "Olivia Martinez",
                                timestamp: "1h",
                                commentText: "Yes, I was there last summer. It's absolutely stunning in person!",
                                reactions: ["like"],
                                reactionCount: 15,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                        }
                    }
                    
                    CommentCard(title: "Comment with image") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .topLevel,
                                profileImage: "profile7",
                                actorName: "Chris Anderson",
                                timestamp: "12h",
                                commentText: "Check out this related photo!",
                                image: "image1",
                                reactions: ["like", "wow"],
                                reactionCount: 45,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                        }
                    }
                    
                    CommentCard(title: "Reply with image") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .reply,
                                profileImage: "profile8",
                                actorName: "Taylor Kim",
                                timestamp: "6h",
                                commentText: "Here's a similar view from a different angle",
                                image: "image2",
                                reactions: ["love"],
                                reactionCount: 23,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                        }
                    }
                    
                    CommentCard(title: "Without action buttons") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .topLevel,
                                profileImage: "profile13",
                                actorName: "Nina Patel",
                                timestamp: "9h",
                                commentText: "Beautiful shot!"
                            )
                        }
                    }
                    
                    CommentCard(title: "Thread with images") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .topLevel,
                                profileImage: "profile9",
                                actorName: "David Park",
                                timestamp: "8h",
                                commentText: "What camera settings did you use for this shot? The colors are incredible!",
                                reactions: ["like", "wow"],
                                reactionCount: 18,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile10",
                                actorName: "Sophia Chen",
                                timestamp: "7h",
                                commentText: "I used a 50mm lens with f/2.8 aperture and ISO 400. Golden hour lighting did most of the work!",
                                image: "image3",
                                reactions: ["like", "support"],
                                reactionCount: 32,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile11",
                                actorName: "Ryan Hughes",
                                timestamp: "6h",
                                commentText: "Thanks for sharing! I've been trying to improve my photography and this is really helpful.",
                                reactions: ["like"],
                                reactionCount: 7,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                        }
                    }
                    
                    CommentCard(title: "Image without text") {
                        VStack(spacing: 0) {
                            FDSComment(
                                type: .topLevel,
                                profileImage: "profile14",
                                actorName: "Alex Morgan",
                                timestamp: "3h",
                                commentText: "",
                                image: "image4",
                                reactions: ["love", "wow"],
                                reactionCount: 67,
                                onReplyTap: {
                                    print("Reply tapped")
                                },
                                onLikeTap: {
                                    print("Like tapped")
                                }
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Preview
#Preview {
    CommentsPreviewView()
}

