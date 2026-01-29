import SwiftUI

// MARK: - Group Type

enum GroupType {
    case publicGroup
    case privateGroup
    case unjoinedPublicGroup
    case unjoinedPrivateGroup
}

// MARK: - Group Data Model

struct GroupData: Hashable {
    let id: String
    let name: String
    let coverImage: String
    let memberCount: String
    let groupType: GroupType
}

// MARK: - Sample Group Data

let groupDataMap: [String: GroupData] = [
    "groupcover": GroupData(
        id: "group1",
        name: "Karaoke Rockstars of Chicago",
        coverImage: "groupcover",
        memberCount: "1.1K",
        groupType: .publicGroup
    ),
    "image7": GroupData(
        id: "group2",
        name: "Bay Area Hiking & Outdoors",
        coverImage: "image7",
        memberCount: "24.5K",
        groupType: .publicGroup
    ),
    "image6": GroupData(
        id: "group3",
        name: "San Francisco Food Lovers",
        coverImage: "image6",
        memberCount: "18.2K",
        groupType: .privateGroup
    ),
    "image8": GroupData(
        id: "group4",
        name: "Tech Startup Founders",
        coverImage: "image8",
        memberCount: "12.8K",
        groupType: .unjoinedPublicGroup
    )
]

struct GroupView: View {
    let group: GroupData
    @State private var selectedIndex = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                    GroupHeader(group: group, topSafeArea: geometry.safeAreaInsets.top)

                FDSSubNavigationBar(
                    items: [
                        SubNavigationItem("You"),
                        SubNavigationItem("Chats"),
                        SubNavigationItem("Featured"),
                        SubNavigationItem("Reels"),
                        SubNavigationItem("About"),
                        SubNavigationItem("Photos"),
                        SubNavigationItem("Events"),
                        SubNavigationItem("Files")
                    ], style: .links
                )
                .padding(.top, 8)
                
                // Group posts
                VStack(spacing: 0) {
                    FDSUnitHeader(headlineText: "All posts", hierarchyLevel: .level3)
                    
                    ForEach(postData.filter { $0.groupImage == group.coverImage }, id: \.id) { post in
                        FeedPost(from: post, disableProfileNavigation: false, hideGroupInfo: true)
                            .id("post-\(post.id)")
                        Separator()
                    }
                    }
                    .background(Color("surfaceBackground"))
                    }
                }
                .background(Color("surfaceBackground"))
                .ignoresSafeArea(edges: .top)
                .toolbar(.hidden, for: .tabBar)
                .navigationDestination(for: PostData.self) { post in
                    PostPermalinkView(post: post)
                }
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
        .hideFDSTabBar(true)
    }
}

// MARK: - Group Header

struct GroupHeader: View {
    let group: GroupData
    let topSafeArea: CGFloat
    
    init(group: GroupData, topSafeArea: CGFloat = 0) {
        self.group = group
        self.topSafeArea = topSafeArea
    }
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Cover Photo
            ZStack(alignment: .top) {
                Image(group.coverImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
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
                .frame(height: 120)
                
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: topSafeArea)
                    FDSNavigationBarCentered(
                        backAction: { dismiss() },
                        onMedia: true,
                        icon1: {
                            FDSIconButton(icon: "magnifying-glass-filled", onMedia: true, action: {})
                        },
                        icon2: {
                            FDSIconButton(icon: "dots-3-horizontal-filled", onMedia: true, action: {})
                        }
                    )
                    .padding(.bottom, 10)
                }
            }
            
            // Group Info Section
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                        .fill(Color("surfaceBackground"))
                        .frame(height: 20)
                        .offset(y: -20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(group.name)
                            .headline2EmphasizedTypography()
                            .foregroundStyle(Color("primaryText"))
                        
                        HStack(spacing: 4) {
                            Image(group.groupType == .privateGroup || group.groupType == .unjoinedPrivateGroup ? "privacy-filled" : "globe-americas-12")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(Color("secondaryIcon"))
                            
                            Text(group.groupType == .privateGroup || group.groupType == .unjoinedPrivateGroup ? "Private group" : "Public group")
                                .meta3Typography()
                                .foregroundStyle(Color("secondaryText"))
                            
                            Text("·")
                                .meta3Typography()
                                .foregroundStyle(Color("secondaryText"))
                            
                            Text(group.memberCount)
                                .meta3LinkTypography()
                                .foregroundStyle(Color("primaryText"))
                            
                            Text("members")
                                .meta3Typography()
                                .foregroundStyle(Color("secondaryText"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
                }
                
                GroupActionButtons(groupType: group.groupType)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Group Action Buttons

struct GroupActionButtons: View {
    let groupType: GroupType
    
    var body: some View {
        HStack(spacing: 8) {
            switch groupType {
            case .unjoinedPublicGroup, .unjoinedPrivateGroup:
                FDSButton(
                    type: .primary,
                    label: "Join group",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )
                
            case .publicGroup, .privateGroup:
                FDSButton(
                    type: .secondary,
                    label: "Joined",
                    icon: "group-checkmark-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )
                
                FDSButton(
                    type: .primary,
                    label: "Invite",
                    icon: "friend-add-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GroupView(group: groupDataMap["groupcover"]!)
    }
    .environmentObject(FDSTabBarHelper())
}

