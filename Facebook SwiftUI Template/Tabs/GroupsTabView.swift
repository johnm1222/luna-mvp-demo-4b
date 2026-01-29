import SwiftUI

struct GroupsTabView: View {
    var bottomPadding: CGFloat = 0
    @State private var selectedTabIndex = 0
    @State private var showSearch = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FDSNavigationBar(
                    title: "Groups",
                    icon1: {
                        FDSIconButton(icon: "plus-square-outline", action: {})
                    },
                    icon2: {
                        FDSIconButton(icon: "profile-outline", action: {})
                    },
                    icon3: {
                        FDSIconButton(icon: "magnifying-glass-outline", action: { showSearch = true })
                    }
                )
                    
                FDSSubNavigationBar(
                    items: [
                        SubNavigationItem("For you"),
                        SubNavigationItem("Your groups"),
                        SubNavigationItem("Posts"),
                        SubNavigationItem("Discover")
                    ],
                    selectedIndex: $selectedTabIndex
                )
                .padding(.top, 8)
                
                FDSUnitHeader(
                    headlineText: "Your groups",
                    hierarchyLevel: .level3
                )
                
                GroupsList()
                
                FDSUnitHeader(
                    headlineText: "From your groups",
                    hierarchyLevel: .level3
                )
                
                GroupPostsFeed()
            }
            .padding(.bottom, bottomPadding)
        }
        .background(Color("surfaceBackground"))
    }
}

struct GroupsList: View {
    let groups = Array(groupDataMap.values).filter { group in
        group.groupType == .publicGroup || group.groupType == .privateGroup
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(groups, id: \.id) { group in
                FDSListCell(
                    hierarchyLevel: .level4,
                    headlineText: group.name,
                    bodyText: "\(group.memberCount) members",
                    leftAddOn: .profilePhoto(group.coverImage, type: .nonActor, size: .size40)
                ) {
                    GroupView(group: group)
                }
            }
        }
    }
}

struct GroupPostsFeed: View {
    let groupPosts = postData.filter { $0.groupImage != nil }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(groupPosts, id: \.id) { post in
                FeedPost(from: post)
                    .id("post-\(post.id)")
                Separator()
            }
        }
    }
}

#Preview {
    GroupsTabView()
        .environmentObject(FDSTabBarHelper())
}

