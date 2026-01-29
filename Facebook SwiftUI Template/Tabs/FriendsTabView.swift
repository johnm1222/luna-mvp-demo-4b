import SwiftUI

// MARK: - Friends Tab

struct FriendsTab: View {
    var bottomPadding: CGFloat = 0
    @State private var showSearch = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                FDSNavigationBar(
                    title: "Friends",
                    icon1: {
                        Menu {
                                Button(action: {}) {
                                    Label("Post", image: "compose-outline")
                                }
                                Button(action: {}) {
                                    Label("Story", image: "instagram-new-story-outline")
                                }
                                Button(action: {}) {
                                    Label("Reel", image: "app-facebook-reels-outline")
                                }
                                Button(action: {}) {
                                    Label("Live", image: "camcorder-live-outline")
                                }
                                Button(action: {}) {
                                    Label("Note", image: "content-note-outline")
                                }
                            } label: {
                                FDSIconButton(icon: "plus-square-outline", action: {})
                            }
                            .tint(Color("primaryIcon"))
                        },
                        icon2: {
                            FDSIconButton(icon: "magnifying-glass-outline", action: { showSearch = true })
                        },
                        icon3: {
                            FDSIconButton(icon: "app-messenger-outline", action: {
                                if let url = URL(string: "msgrproto://") {
                                    UIApplication.shared.open(url)
                                }
                            })
                        }
                    )
                    FDSSubNavigationBar(
                        items: [
                            SubNavigationItem("Requests"),
                            SubNavigationItem("Pokes"),
                            SubNavigationItem("Birthdays"),
                            SubNavigationItem("Your friends"),
                        ], style: .links
                    )
                    .padding(.top, 8)
                    StoriesTray()
                    ForEach(
                        postData.filter { post in
                            guard post.profileImage != "profile1" else { return false }
                            guard post.groupName == nil else { return false }
                            let relationship = profileDataMap[post.profileImage]?.relationshipType ?? .stranger
                            return relationship != .stranger
                        },
                        id: \.id
                    ) { post in
                        Separator()
                        FeedPost(from: post)
                            .id("post-\(post.id)")
                    }
                    }
                    .padding(.bottom, bottomPadding)
            }
            .background(Color("surfaceBackground"))
        }
    }
}

#Preview {
    FriendsTab()
        .environmentObject(FDSTabBarHelper())
}

