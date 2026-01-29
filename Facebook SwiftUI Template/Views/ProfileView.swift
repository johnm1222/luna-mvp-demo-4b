import SwiftUI

// MARK: - Profile Relationship Type

enum ProfileRelationship {
    case currentUser
    case friend
    case stranger
}

// MARK: - Profile Data Model

struct ProfileData: Hashable {
    let id: String
    let name: String
    let profileImage: String
    let coverImage: String
    let bio: String
    let friendCount: Int
    let postCount: Int
    let location: String?
    let work: String?
    let education: String?
    let relationship: String?
    let instagram: String?
    let relationshipType: ProfileRelationship
    
    static let currentUser = ProfileData(
        id: "profile1",
        name: "Daniela Giménez",
        profileImage: "profile1",
        coverImage: "image3",
        bio: "Coffee enthusiast ☕",
        friendCount: 423,
        postCount: 287,
        location: "San Francisco, CA",
        work: "Designer at Apple",
        education: "Stanford University",
        relationship: "In a relationship",
        instagram: "sarahchen",
        relationshipType: .currentUser
    )
}

// MARK: - Sample Profile Data

let profileDataMap: [String: ProfileData] = [
    "profile1": ProfileData.currentUser,
    "profile2": ProfileData(
        id: "profile2",
        name: "Bob Johnson",
        profileImage: "profile2",
        coverImage: "image4",
        bio: "Living life one adventure at a time.",
        friendCount: 189,
        postCount: 142,
        location: "Portland, OR",
        work: "Freelance Photographer",
        education: "Portland State University",
        relationship: nil,
        instagram: "bobjohnson",
        relationshipType: .stranger
    ),
    "profile3": ProfileData(
        id: "profile3",
        name: "Alice Smith",
        profileImage: "profile3",
        coverImage: "image1",
        bio: "Vintage clothing collector 🌼",
        friendCount: 567,
        postCount: 421,
        location: "Brooklyn, NY",
        work: "Vintage Shop Owner",
        education: "Parsons School of Design",
        relationship: "Single",
        instagram: "alicesmith",
        relationshipType: .stranger
    ),
    "profile4": ProfileData(
        id: "profile4",
        name: "Diana Ross",
        profileImage: "profile4",
        coverImage: "image5",
        bio: "Skater • Artist • Explorer",
        friendCount: 312,
        postCount: 198,
        location: "Salt Lake City, UT",
        work: "Graphic Designer",
        education: "University of Utah",
        relationship: nil,
        instagram: "dianaross",
        relationshipType: .friend
    ),
    "profile5": ProfileData(
        id: "profile5",
        name: "Alex Kim",
        profileImage: "profile5",
        coverImage: "image6",
        bio: "Baker & food content creator 🍰",
        friendCount: 891,
        postCount: 654,
        location: "Los Angeles, CA",
        work: "Content Creator",
        education: "Culinary Institute",
        relationship: "Married",
        instagram: "alexkim",
        relationshipType: .friend
    ),
    "profile6": ProfileData(
        id: "profile6",
        name: "Tina Wright",
        profileImage: "profile6",
        coverImage: "image7",
        bio: "Tech enthusiast • Gamer • Cat dad",
        friendCount: 234,
        postCount: 167,
        location: "Seattle, WA",
        work: "Software Engineer at Microsoft",
        education: "University of Washington",
        relationship: nil,
        instagram: "marcuswong",
        relationshipType: .friend
    ),
    "profile7": ProfileData(
        id: "profile7",
        name: "Taina Thomsen",
        profileImage: "profile7",
        coverImage: "image8",
        bio: "Home chef • Recipe developer",
        friendCount: 445,
        postCount: 289,
        location: "Austin, TX",
        work: "Food Blogger",
        education: "Texas Culinary Academy",
        relationship: "Single",
        instagram: "tainathomsen",
        relationshipType: .friend
    ),
    "profile8": ProfileData(
        id: "profile8",
        name: "Jamie Lee",
        profileImage: "profile8",
        coverImage: "image1",
        bio: "Fitness coach • Wellness advocate",
        friendCount: 723,
        postCount: 512,
        location: "Miami, FL",
        work: "Personal Trainer",
        education: "Florida State University",
        relationship: "Engaged",
        instagram: "jamielee",
        relationshipType: .friend
    ),
    "profile9": ProfileData(
        id: "profile9",
        name: "Fatih Tekin",
        profileImage: "profile9",
        coverImage: "image5",
        bio: "Dog lover 🐶 • Costume designer",
        friendCount: 378,
        postCount: 256,
        location: "Chicago, IL",
        work: "Costume Designer",
        education: "School of the Art Institute",
        relationship: nil,
        instagram: "fatihtekin",
        relationshipType: .friend
    ),
    "profile10": ProfileData(
        id: "profile10",
        name: "Ana Santos",
        profileImage: "profile12",
        coverImage: "image2",
        bio: "Probably off wandering somewhere.",
        friendCount: 245,
        postCount: 153,
        location: "Lawrence, KS",
        work: "Walmart",
        education: "University of Kansas",
        relationship: "Single",
        instagram: "anasantos",
        relationshipType: .friend
    ),
    "profile11": ProfileData(
        id: "profile11",
        name: "Kelsey Fung",
        profileImage: "profile11",
        coverImage: "image3",
        bio: "Music producer • DJ",
        friendCount: 667,
        postCount: 401,
        location: "Nashville, TN",
        work: "Music Producer",
        education: "Berklee College of Music",
        relationship: "In a relationship",
        instagram: "ryanmartinez",
        relationshipType: .friend
    ),
    "profile12": ProfileData(
        id: "profile10",
        name: "John Stockholm",
        profileImage: "profile12",
        coverImage: "image2",
        bio: "Nature photographer 📸",
        friendCount: 456,
        postCount: 334,
        location: "Denver, CO",
        work: "Nature Photographer",
        education: "Rocky Mountain College",
        relationship: "Single",
        instagram: "stockholmie",
        relationshipType: .friend
    ),
]

struct ProfileView: View {
    let profile: ProfileData
    @State private var selectedIndex = 0 
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                    ProfileHeader(profile: profile, topSafeArea: geometry.safeAreaInsets.top)

                FDSSubNavigationBar(
                    items: [
                        SubNavigationItem("All"),
                        SubNavigationItem("Photos"),
                        SubNavigationItem("Reels")
                    ],
                    selectedIndex: $selectedIndex
                )
                .padding(.top, 8)
                
                // Profile posts
                VStack(spacing: 0) {
                    FDSUnitHeader(headlineText: "All posts", hierarchyLevel: .level3)
                    
                    ForEach(postData.filter { $0.profileImage == profile.profileImage }, id: \.id) { post in
                        FeedPost(from: post, disableProfileNavigation: true)
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

// MARK: - Profile Header

struct ProfileHeader: View {
    let profile: ProfileData
    let topSafeArea: CGFloat
    
    init(profile: ProfileData, topSafeArea: CGFloat = 0) {
        self.profile = profile
        self.topSafeArea = topSafeArea
    }
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Cover Photo
                ZStack(alignment: .top) {
                    Image(profile.coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
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
                }
                
                // Profile Info Section
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                            .fill(Color("surfaceBackground"))
                            .frame(height: 20)
                            .offset(y: -20)
                        
                        HStack(alignment: .bottom, spacing: 12) {
                            Spacer()
                                .frame(width: 104)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text(profile.name)
                                    .headline2EmphasizedTypography()
                                    .foregroundStyle(Color("primaryText"))
                                
                                WrappingHStack(spacing: 4) {
                                    HStack(spacing: 4) {
                                        Text("\(profile.friendCount)")
                                            .meta3LinkTypography()
                                            .foregroundStyle(Color("primaryText"))
                                        Text("friends")
                                            .meta3Typography()
                                            .foregroundStyle(Color("primaryText"))
                                    }
                                    .fixedSize()
                                    
                                    Text("·")
                                        .meta3Typography()
                                        .foregroundStyle(Color("primaryText"))
                                    
                                    HStack(spacing: 4) {
                                        Text("\(profile.postCount)")
                                            .meta3LinkTypography()
                                            .foregroundStyle(Color("primaryText"))
                                        Text("posts")
                                            .meta3Typography()
                                            .foregroundStyle(Color("primaryText"))
                                    }
                                    .fixedSize()
                                }
                            }
                            .padding(.bottom, 16)
                            .offset(y: -5)
                            .frame(height: 52)
                            
                            if profile.relationshipType == .currentUser {
                                Button(action: {}) {
                                    ZStack {
                                        Circle()
                                            .fill(Color("secondaryButtonBackground"))
                                            .frame(width: 32, height: 32)
                                        
                                        // Notification badge
                                        Circle()
                                            .fill(Color("decorativeIconRed"))
                                            .frame(width: 6, height: 6)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color("surfaceBackground"), lineWidth: 1)
                                            )
                                            .offset(x: 11, y: -11)
                                        
                                        Image("chevron-down-filled")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(Color("secondaryButtonIcon"))
                                    }
                                }
                                .offset(y: -30)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.bio)
                            .body3Typography()
                            .foregroundStyle(Color("primaryText"))
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                        
                        ProfileInfoFlow(profile: profile)
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                        
                        ProfileActionButtons(relationshipType: profile.relationshipType)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                    }
                }
                .background(Color("surfaceBackground"))
            }
            
            // Profile Photo - overlapping layer
            VStack {
                Spacer()
                    .frame(height: 122)
                HStack {
                    ZStack(alignment: .bottomTrailing) {
                        Image(profile.profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color("surfaceBackground"), lineWidth: 4)
                            )
                        
                        if profile.relationshipType == .currentUser {
                            ZStack {
                                Circle()
                                    .fill(Color("surfaceBackground"))
                                    .frame(width: 32, height: 32)
                                Circle()
                                    .fill(Color("secondaryButtonBackground"))
                                    .frame(width: 32, height: 32)
                                Circle()
                                    .stroke(Color("surfaceBackground"), lineWidth: 2)
                                    .frame(width: 32, height: 32)
                                Image("camera-filled")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(Color("primaryIcon"))
                            }
                            .offset(x: 2, y: 2)
                            .cornerRadius(100)
                        }
                    }
                    .padding(.leading, 14)
                    
                    Spacer()
                }
                Spacer()
            }
            
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: topSafeArea)
                if profile.relationshipType == .currentUser {
                    FDSNavigationBarCentered(
                        backAction: { dismiss() },
                        onMedia: true,
                        icon1: {
                            FDSIconButton(icon: "pencil-filled", onMedia: true, action: {})
                        },
                        icon2: {
                            FDSIconButton(icon: "dots-3-horizontal-filled", onMedia: true, action: {})
                        },
                        icon3: {
                            FDSIconButton(icon: "magnifying-glass-filled", onMedia: true, action: {})
                        }
                    )
                    .padding(.bottom, 10)
                } else {
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
        }
    }
}

// MARK: - Profile Action Buttons

struct ProfileActionButtons: View {
    let relationshipType: ProfileRelationship
    
    var body: some View {
        HStack(spacing: 8) {
            switch relationshipType {
            case .currentUser:
                FDSButton(
                    type: .primary,
                    label: "Add to story",
                    icon: "plus-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )
                
                FDSButton(
                    type: .secondary,
                    label: "Edit profile",
                    icon: "pencil-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )
                
                FDSButton(
                    type: .secondary,
                    icon: "dots-3-horizontal-filled",
                    size: .medium,
                    widthMode: .constrained,
                    action: {}
                )
                
            case .friend:
                FDSButton(
                    type: .secondary,
                    label: "Friends",
                    icon: "friends-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )
                
                FDSButton(
                    type: .primary,
                    label: "Message",
                    icon: "app-messenger-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )
                
                FDSButton(
                    type: .secondary,
                    icon: "poke-filled",
                    size: .medium,
                    widthMode: .constrained,
                    action: {}
                )
                
            case .stranger:
                FDSButton(
                    type: .primary,
                    label: "Follow",
                    icon: "follow-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )
                
                FDSButton(
                    type: .secondary,
                    label: "Message",
                    icon: "app-messenger-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )
            }
        }
    }
}

// MARK: - Profile Info Flow Layout

struct ProfileInfoFlow: View {
    let profile: ProfileData
    
    private var infoItems: [(icon: String, text: String)] {
        var items: [(icon: String, text: String)] = []
        
        if let location = profile.location {
            items.append(("location-filled", location))
        }
        if let work = profile.work {
            items.append(("briefcase-filled", work))
        }
        if let education = profile.education {
            items.append(("mortar-board-filled", education))
        }
        if let relationship = profile.relationship {
            items.append(("heart-filled", relationship))
        }
        if let instagram = profile.instagram {
            items.append(("app-instagram-outline", instagram))
        }
        
        return items
    }
    
    var body: some View {
        WrappingHStack(spacing: 8) {
            ForEach(Array(infoItems.enumerated()), id: \.offset) { index, item in
                ProfileInfoItem(icon: item.icon, text: item.text)
                if index < infoItems.count - 1 {
                    ProfileInfoDot()
                }
            }
        }
    }
}

// MARK: - Profile Info Item

struct ProfileInfoItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Image(icon)
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundColor(Color("primaryIcon"))
            
            Text(text)
                .body4LinkTypography()
                .foregroundStyle(Color("primaryText"))
        }
    }
}

// MARK: - Profile Info Dot

struct ProfileInfoDot: View {
    var body: some View {
        Text("·")
            .body3LinkTypography()
            .foregroundStyle(Color("secondaryText"))
    }
}

// MARK: - Wrapping HStack Layout

struct WrappingHStack: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var lineHeight: CGFloat = 0
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView(profile: .currentUser)
    }
    .environmentObject(FDSTabBarHelper())
}
