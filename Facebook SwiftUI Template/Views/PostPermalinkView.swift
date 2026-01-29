import SwiftUI

struct UserComment: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: String
}

struct PostPermalinkView: View {
    let post: PostData
    @Environment(\.dismiss) private var dismiss
    
    @State private var commentText: String = ""
    @FocusState private var isCommentFieldFocused: Bool
    @State private var isThread1Expanded = false
    @State private var isThread2Expanded = false
    @State private var userComments: [UserComment] = []

    private var isSendButtonDisabled: Bool {
        commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func submitComment() {
        let trimmedText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newComment = UserComment(text: trimmedText, timestamp: "Just now")
        userComments.append(newComment)
        commentText = ""
        isCommentFieldFocused = false
    }

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Post",
                backAction: { dismiss() },
                icon1: {
                    PostMenuView(size: .size24, color: .primary)
                },
            )
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        FeedPost(from: post, isPermalink: true)
                        FDSUnitHeader(headlineText: "Comments", hierarchyLevel: .level3)
                    
                    // Comment thread
                    VStack(spacing: 0) {
                        // First comment with replies
                        FDSComment(
                            type: .topLevel,
                            profileImage: "profile2",
                            actorName: "Mike Chen",
                            timestamp: "3h",
                            commentText: "This is absolutely stunning! Where was this taken?",
                            reactions: ["like", "love", "wow"],
                            reactionCount: 142,
                            onReplyTap: {},
                            onLikeTap: {}
                        )
                        
                        FDSComment(
                            type: .reply,
                            profileImage: "profile1",
                            actorName: "Sarah Johnson",
                            timestamp: "2h",
                            commentText: "Thanks! This was at Waimea Bay in Oahu 🌊",
                            reactions: ["like", "love"],
                            reactionCount: 89,
                            onReplyTap: {},
                            onLikeTap: {}
                        )
                        
                        FDSComment(
                            type: .reply,
                            profileImage: "profile3",
                            actorName: "Alex Rivera",
                            timestamp: "2h",
                            commentText: "I knew it! Been there last summer, such an amazing place.",
                            reactions: ["like"],
                            reactionCount: 34,
                            onReplyTap: {},
                            onLikeTap: {}
                        )
                        
                        // Second comment with image
                        FDSComment(
                            type: .topLevel,
                            profileImage: "profile4",
                            actorName: "Emma Wilson",
                            timestamp: "5h",
                            commentText: "Reminds me of my trip there! Here's a similar shot I got:",
                            image: "ocean",
                            reactions: ["love", "wow"],
                            reactionCount: 98,
                            onReplyTap: {},
                            onLikeTap: {}
                        )
                        
                        FDSComment(
                            type: .reply,
                            profileImage: "profile1",
                            actorName: "Sarah Johnson",
                            timestamp: "4h",
                            commentText: "Wow, beautiful capture!",
                            reactions: ["love"],
                            reactionCount: 12,
                            onReplyTap: {},
                            onLikeTap: {}
                        )
                        
                        // Third comment with expandable thread
                        FDSComment(
                            type: .topLevel,
                            profileImage: "profile5",
                            actorName: "James Lee",
                            timestamp: "8h",
                            commentText: "What camera settings did you use? The colors are incredible!",
                            reactions: ["like"],
                            reactionCount: 67,
                            onReplyTap: {},
                            onLikeTap: {}
                        )
                        
                        FDSCommentPager(replyCount: 5, isExpanded: $isThread1Expanded)
                        
                        if isThread1Expanded {
                            FDSComment(
                                type: .reply,
                                profileImage: "profile1",
                                actorName: "Sarah Johnson",
                                timestamp: "7h",
                                commentText: "Shot with a Sony A7 III, 24-70mm at f/4, ISO 200. Golden hour magic! ✨",
                                reactions: ["like", "support"],
                                reactionCount: 156,
                                onReplyTap: {},
                                onLikeTap: {}
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                                removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                            ))
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile6",
                                actorName: "Olivia Martinez",
                                timestamp: "6h",
                                commentText: "Thanks for sharing! Just got the same setup.",
                                reactions: ["like"],
                                reactionCount: 23,
                                onReplyTap: {},
                                onLikeTap: {}
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                                removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                            ))
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile7",
                                actorName: "Chris Anderson",
                                timestamp: "5h",
                                commentText: "The 24-70mm is such a versatile lens!",
                                reactions: ["like"],
                                reactionCount: 18,
                                onReplyTap: {},
                                onLikeTap: {}
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                                removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                            ))
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile8",
                                actorName: "Taylor Kim",
                                timestamp: "4h",
                                commentText: "I need to upgrade my gear 😅",
                                reactions: ["haha"],
                                reactionCount: 45,
                                onReplyTap: {},
                                onLikeTap: {}
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                                removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                            ))
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile9",
                                actorName: "David Park",
                                timestamp: "3h",
                                commentText: "Skill > gear, but good gear helps! 📸",
                                reactions: ["like", "support"],
                                reactionCount: 67,
                                onReplyTap: {},
                                onLikeTap: {}
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                                removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                            ))
                        }
                        
                        // Simple comment
                        FDSComment(
                            type: .topLevel,
                            profileImage: "profile10",
                            actorName: "Sophia Chen",
                            timestamp: "12h",
                            commentText: "Goals! 🌴",
                            reactions: ["love"],
                            reactionCount: 24,
                            onReplyTap: {},
                            onLikeTap: {}
                        )
                        
                        // Another comment with thread
                        FDSComment(
                            type: .topLevel,
                            profileImage: "profile11",
                            actorName: "Ryan Hughes",
                            timestamp: "1d",
                            commentText: "I miss Hawaii so much! Best vacation ever.",
                            reactions: ["like", "sad"],
                            reactionCount: 78,
                            onReplyTap: {},
                            onLikeTap: {}
                        )
                        
                        FDSCommentPager(replyCount: 3, isExpanded: $isThread2Expanded)
                        
                        if isThread2Expanded {
                            FDSComment(
                                type: .reply,
                                profileImage: "profile12",
                                actorName: "Jessica Wu",
                                timestamp: "22h",
                                commentText: "Same! Already planning my next trip back.",
                                reactions: ["like"],
                                reactionCount: 15,
                                onReplyTap: {},
                                onLikeTap: {}
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                                removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                            ))
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile13",
                                actorName: "Marcus Brown",
                                timestamp: "20h",
                                commentText: "The North Shore is unbeatable 🏄‍♂️",
                                image: "jade-video",
                                reactions: ["love", "wow"],
                                reactionCount: 43,
                                onReplyTap: {},
                                onLikeTap: {}
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                                removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                            ))
                            
                            FDSComment(
                                type: .reply,
                                profileImage: "profile14",
                                actorName: "Nina Patel",
                                timestamp: "18h",
                                commentText: "Adding it to my bucket list!",
                                reactions: ["support"],
                                reactionCount: 8,
                                onReplyTap: {},
                                onLikeTap: {}
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.moveIn(MotionDuration.shortIn)),
                                removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                            ))
                        }
                        
                        // Final simple comment
                        FDSComment(
                            type: .topLevel,
                            profileImage: "profile15",
                            actorName: "Rachel Green",
                            timestamp: "2d",
                            commentText: "Beautiful! 💙",
                            reactions: ["love"],
                            reactionCount: 18,
                            onReplyTap: {},
                            onLikeTap: {}
                        )
                        
                        // User submitted comments
                        ForEach(userComments) { comment in
                            FDSComment(
                                type: .topLevel,
                                profileImage: "profile1",
                                actorName: "Sarah Johnson",
                                timestamp: comment.timestamp,
                                commentText: comment.text,
                                onReplyTap: {},
                                onLikeTap: {}
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity).animation(.moveIn(MotionDuration.shortIn)),
                                removal: .opacity.animation(.moveOut(MotionDuration.shortOut))
                            ))
                        }
                        
                        // Invisible anchor for scrolling
                        Color.clear
                            .frame(height: 1)
                            .id("bottomAnchor")
                    }
                }
                .padding(.bottom, 12)
                }
                .background(Color("surfaceBackground"))
                .onChange(of: userComments.count) { oldValue, newValue in
                    if newValue > oldValue {
                        withAnimation(.moveIn(MotionDuration.shortIn)) {
                            proxy.scrollTo("bottomAnchor", anchor: .bottom)
                        }
                    }
                }
            }
            
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image("profile1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    HStack(spacing: 8) {
                        TextField("Add a comment...", text: $commentText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .body3Typography()
                            .foregroundStyle(Color("primaryText"))
                            .lineLimit(1...2)
                            .frame(minHeight: 40)
                            .focused($isCommentFieldFocused)
                            .onSubmit {
                                submitComment()
                            }
                        HStack(spacing: 12) {
                            FDSIconButton(
                                icon: "app-facebook-avatars-outline",
                                size: .size20,
                                color: .secondary,
                                action: {}
                            )
                            FDSIconButton(
                                icon: "camera-outline",
                                size: .size20,
                                color: .secondary,
                                action: {}
                            )
                            FDSIconButton(
                                icon: "gif-outline",
                                size: .size20,
                                color: .secondary,
                                action: {}
                            )
                            FDSIconButton(
                                icon: "emoji-outline",
                                size: .size20,
                                color: .secondary,
                                action: {}
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                    .background(Color("textInputBarBackground"))
                    .cornerRadius(20)
                    .animation(.swapShuffleIn(MotionDuration.shortIn), value: isSendButtonDisabled)
                    
                    if !isSendButtonDisabled {
                        FDSIconButton(
                            icon: "send-filled",
                            color: .accent,
                            action: {
                                submitComment()
                            }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity).animation(.swapShuffleIn(MotionDuration.shortIn)),
                                removal: .scale(scale: 0.8).combined(with: .opacity).animation(.swapShuffleOut(MotionDuration.shortOut))
                            )
                        )
                    }
                }
                .animation(.swapShuffleIn(MotionDuration.shortIn), value: isSendButtonDisabled)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color("surfaceBackground"))
                .shadow(color: Color("borderPersistentUi"), radius: 0, x: 0, y: -0.5)
            }
            .animation(.swapShuffleIn(MotionDuration.shortIn), value: isCommentFieldFocused)
        }
        .toolbar(.hidden, for: .tabBar)
        .hideFDSTabBar(true)
        .navigationDestination(for: String.self) { profileImageId in
            if let profileData = profileDataMap[profileImageId] {
                ProfileView(profile: profileData)
            }
        }
        .navigationDestination(for: GroupNavigationValue.self) { groupNav in
            if let groupData = groupDataMap[groupNav.groupImage] {
                GroupView(group: groupData)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostPermalinkView(post: postData[0])
    }
    .environmentObject(FDSTabBarHelper())
}
