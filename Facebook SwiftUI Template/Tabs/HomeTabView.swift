import SwiftUI
import SafariServices

// MARK: - Navigation Value Types

struct GroupNavigationValue: Hashable {
    let groupImage: String
}

// MARK: Home Tab

struct HomeTab: View {
    var bottomPadding: CGFloat = 0
    @State private var showSearch = false
    @State private var navigationToPrototypeSettings = false
    @EnvironmentObject private var tabBarHelper: FDSTabBarHelper
    @State private var isNavigating = false

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        FDSNavigationBar(logoAction: { navigationToPrototypeSettings = true }, icon1: {
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
                        }, icon2: {
                            FDSIconButton(icon: "magnifying-glass-outline", action: { showSearch = true })
                        }, icon3: {
                            FDSIconButton(icon: "app-messenger-outline", action: {
                                if let url = URL(string: "msgrproto://") {
                                    UIApplication.shared.open(url)
                                }
                            })
                        })
                        PostComposer()
                        StoriesTray()
                        ForEach(postData.filter { $0.profileImage != "profile1" }, id: \.id) { post in
                            Separator()
                            FeedPost(from: post)
                                .id("post-\(post.id)")
                        }
                    }
                    .padding(.bottom, bottomPadding)
                }
                .hideTabBarOnScrollWithDwell(threshold: 0, dwellTime: 1.5)
                .background(Color("surfaceBackground"))
                .onAppear {
                    DispatchQueue.main.async {
                        tabBarHelper.isHomeTabActive = true
                    }
                }
                .onDisappear {
                    DispatchQueue.main.async {
                        tabBarHelper.isHomeTabActive = false
                    }
                }
            }
            .navigationDestination(isPresented: $showSearch) {
                SearchView()
                    .onAppear { isNavigating = true }
                    .onDisappear { isNavigating = false }
            }
            .navigationDestination(isPresented: $navigationToPrototypeSettings) {
                PrototypeSettings()
                    .onAppear { isNavigating = true }
                    .onDisappear { isNavigating = false }
            }
            .navigationDestination(for: PostData.self) { post in
                PostPermalinkView(post: post)
                    .onAppear { isNavigating = true }
                    .onDisappear { isNavigating = false }
            }
            .navigationDestination(for: String.self) { profileImageId in
                if let profileData = profileDataMap[profileImageId] {
                    ProfileView(profile: profileData)
                        .onAppear { isNavigating = true }
                        .onDisappear { isNavigating = false }
                }
            }
            .navigationDestination(for: GroupNavigationValue.self) { groupNav in
                if let groupData = groupDataMap[groupNav.groupImage] {
                    GroupView(group: groupData)
                        .onAppear { isNavigating = true }
                        .onDisappear { isNavigating = false }
                }
            }
        }
    }
}

// MARK: - Separator

struct Separator: View {
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundColor(Color("wash"))
    }
}

// MARK: - Post Composer

struct PostComposer: View {
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            NavigationLink(value: "profile1") {
                Image("profile1")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(100)
            }
            Text("What's on your mind?")
                .body3Typography()
                .foregroundStyle(Color("secondaryText"))
            Spacer()
            FDSIconButton(icon: "photo-filled", color: .secondary, action: {})
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(Color("surfaceBackground"))

    }
}

// MARK: - Stories Tray

struct StoriesTray: View {
    @State private var showStories = false
    @State private var selectedStoryIndex = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                StoryTile(userName: "Add to Story", storyImage: "story0", profileImage: "plus-filled")
                    .frame(width: 114, height: 203)
                ForEach(Array(storyData.enumerated()), id: \.element.profileImage) { index, story in
                    Button {
                        selectedStoryIndex = index
                        showStories = true
                    } label: {
                        StoryTile(userName: story.userName, storyImage: story.storyImage, profileImage: story.profileImage)
                            .frame(width: 114, height: 203)
                    }
                    .buttonStyle(FDSPressedState(cornerRadius: 12, scale: .medium))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(Color("surfaceBackground"))
        .fullScreenCover(isPresented: $showStories) {
            StoriesView(isPresented: $showStories, stories: storyData, startingIndex: selectedStoryIndex)
        }
    }
}

// MARK: - Stories Tile

struct StoryTile: View {
    var userName: String
    var storyImage: String
    var profileImage: String
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                Image(storyImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .background(Color.clear)
                VStack(alignment: .leading) {
                    if userName == "Add to Story" {
                        ZStack {
                            Image(profileImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color("secondaryButtonIconOnMedia"))
                                .padding(4)
                                .background(Color("secondaryButtonBackgroundOnMedia"))
                                .cornerRadius(32)
                        }
                        .padding(8)
                    } else {
                        Image(profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("accentColor"), lineWidth: 3))
                            .padding(8)
                    }
                    Spacer()
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            stops: [
                                .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                                .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.3),
                                .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.7),
                                .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 1.0)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 60)
                        HStack(alignment: .center, spacing: 4) {
                            Text(userName)
                                .body4LinkTypography()
                                .foregroundColor(Color("primaryTextOnMedia"))
                                .textOnMediaShadow()
                        }
                        .padding(8)
                    }
                }
            }
            .cornerRadius(12)
        }
    }
}

// MARK: - Post Header Content

struct PostHeaderContent: View {
    let post: PostData
    let relationshipType: ProfileRelationship
    let disableProfileNavigation: Bool
    let hideGroupInfo: Bool

    var isGroupPost: Bool {
        post.groupName != nil && !hideGroupInfo
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Profile photo lockup
            if isGroupPost {
                groupPhotoLockup
            } else {
                profilePhoto
            }

            // Text content
            VStack(alignment: .leading, spacing: 10) {
                // Headline (actor name for normal posts, group name for group posts)
                HStack(alignment: .center, spacing: 4) {
                    if isGroupPost {
                        groupHeadline
                    } else {
                        actorHeadline
                    }
                }

                // Timestamp with actor name for group posts
                HStack(alignment: .center, spacing: 4) {
                    if isGroupPost {
                        actorNameLink
                        Text("·")
                            .meta4Typography()
                            .foregroundStyle(Color("secondaryText"))
                    }

                    Text(post.timeStamp)
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                    Text("·")
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                    Image("globe-americas-12")
                        .foregroundColor(Color("secondaryIcon"))
                        .frame(width: 12, height: 12)
                        .frame(height: 8)
                }
                .allowsHitTesting(isGroupPost) // Allow clicks on actor name for group posts
            }
            .frame(minHeight: 40)
        }
    }

    @ViewBuilder
    private var profilePhoto: some View {
        if disableProfileNavigation {
            Image(post.profileImage)
                .resizable()
                .frame(width: 40, height: 40)
                .cornerRadius(25)
        } else {
            NavigationLink(value: post.profileImage) {
                Image(post.profileImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(25)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var groupPhotoLockup: some View {
        if let groupImage = post.groupImage, !disableProfileNavigation {
            NavigationLink(value: GroupNavigationValue(groupImage: groupImage)) {
                groupPhotoLockupContent
            }
            .buttonStyle(.plain)
        } else {
            groupPhotoLockupContent
        }
    }

    private var groupPhotoLockupContent: some View {
        ZStack(alignment: .bottomTrailing) {
            // Group image (rounded rectangle)
            if let groupImage = post.groupImage {
                Image(groupImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                    .offset(x: 0, y: 0)
            }

            // Cutout circle (creates the negative space)
            Circle()
                .fill(Color("surfaceBackground"))
                .frame(width: 26, height: 26)
                .offset(x: 2, y: 2)

            // Actor profile photo (circular, overlapping)
            Image(post.profileImage)
                .resizable()
                .frame(width: 24, height: 24)
                .cornerRadius(12)
                .offset(x: 1, y: 1)
        }
        .frame(width: 40, height: 40)
    }

    // MARK: - Headline Components

    @ViewBuilder
    private var actorHeadline: some View {
        // Actor name - links to profile
        if disableProfileNavigation {
            Text(post.userName)
                .headline4Typography()
                .foregroundStyle(Color("primaryText"))
        } else {
            NavigationLink(value: post.profileImage) {
                Text(post.userName)
                    .headline4Typography()
                    .foregroundStyle(Color("primaryText"))
            }
            .buttonStyle(FDSPressedState(
                cornerRadius: 6,
                padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
            ))
        }

        // Follow button (separate action)
        if relationshipType == .stranger && !disableProfileNavigation {
            Text("·")
                .headline4Typography()
                .foregroundStyle(Color("primaryText"))
            Button {
                // Follow action
            } label: {
                Text("Follow")
                    .headline4Typography()
                    .foregroundStyle(Color("blueLink"))
            }
            .buttonStyle(FDSPressedState(
                cornerRadius: 6,
                padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
            ))
        }
    }

    @ViewBuilder
    private var groupHeadline: some View {
        if let groupName = post.groupName, let groupImage = post.groupImage {
            if disableProfileNavigation {
                Text(groupName)
                    .headline4Typography()
                    .foregroundStyle(Color("primaryText"))
            } else {
                NavigationLink(value: GroupNavigationValue(groupImage: groupImage)) {
                    Text(groupName)
                        .headline4Typography()
                        .foregroundStyle(Color("primaryText"))
                }
                .buttonStyle(FDSPressedState(
                    cornerRadius: 6,
                    padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
                ))
            }
        }
    }

    @ViewBuilder
    private var actorNameLink: some View {
        if disableProfileNavigation {
            Text(post.userName)
                .meta4LinkTypography()
                .foregroundStyle(Color("secondaryText"))
        } else {
            NavigationLink(value: post.profileImage) {
                Text(post.userName)
                    .meta4LinkTypography()
                    .foregroundStyle(Color("secondaryText"))
            }
            .buttonStyle(FDSPressedState(
                cornerRadius: 6,
                padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
            ))
        }
    }
}

// MARK: - Feed Post

struct FeedPost: View {
    let post: PostData
    let isPermalink: Bool
    let disableProfileNavigation: Bool
    let hideGroupInfo: Bool
    @State private var isLiked: Bool = false
    @State private var likeCount: Int
    @State private var safariURL: IdentifiableURL?
    @State private var commentCount: Int
    @State private var reactions: [String]
    @EnvironmentObject private var tabBarHelper: FDSTabBarHelper

    private var relationshipType: ProfileRelationship {
        profileDataMap[post.profileImage]?.relationshipType ?? .stranger
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            let thousands = Double(number) / 1000.0
            if thousands.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(thousands))K"
            } else {
                return String(format: "%.1fK", thousands)
            }
        }
        return "\(number)"
    }

    init(from post: PostData, isPermalink: Bool = false, disableProfileNavigation: Bool = false, hideGroupInfo: Bool = false) {
        self.post = post
        self.isPermalink = isPermalink
        self.disableProfileNavigation = disableProfileNavigation
        self.hideGroupInfo = hideGroupInfo
        self.likeCount = Int.random(in: 3...2000)
        self.commentCount = Int.random(in: 3...2000)
        self.reactions = Array(["like", "love", "haha", "support"].shuffled().prefix(Int.random(in: 2...3)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            postHeader

            if let text = post.text {
                Group {
                    if text.count < 83 && post.attachment == nil {
                        Text(text)
                            .body1Typography()
                            .foregroundStyle(Color("primaryText"))
                    } else {
                        Text(text)
                            .body3Typography()
                            .foregroundStyle(Color("primaryText"))
                    }
                }
            }

            if let attachment = post.attachment {
                attachmentView(for: attachment)
                    .zIndex(2)
            }

            if let actionChips = post.actionChips, !actionChips.isEmpty {
                ActionChipHScroll(spacing: 8) {
                    ForEach(actionChips.indices, id: \.self) { index in
                        let chip = actionChips[index]
                        FDSActionChip(
                            size: .large,
                            label: chip.label,
                            leftAddOn: chip.iconName != nil ? .expressiveIconAsset(chip.iconName!) : nil,
                            action: {}
                        )
                    }
                }
                .padding(.horizontal, -12)
            }

            HStack(spacing: 4) {
                InlineReactions(reactions: reactions)
                Text(formatNumber(likeCount))
                    .body3Typography()
                    .foregroundColor(Color("secondaryText"))
                    .contentTransition(.numericText())
                Spacer()
                Text("\(formatNumber(commentCount)) comments")
                    .body3Typography()
                    .foregroundColor(Color("secondaryText"))
            }

            HStack(alignment: .center, spacing: 0) {
                ReactionPicker(
                    onSelect: { reaction in
                        withAnimation {
                            if !isLiked {
                                likeCount += 1
                                isLiked = true
                            }
                        }
                    },
                    onDeselect: {
                        withAnimation {
                            if isLiked {
                                likeCount -= 1
                                isLiked = false
                            }
                        }
                    }
                )

                if isPermalink {
                    Button(action: {}) {
                        Label("Comment", image: "comment-outline-20")
                            .body4LinkTypography()
                            .foregroundColor(Color("secondaryText"))
                    }
                    .buttonStyle(PostActionButtonStyle())
                } else {
                    NavigationLink(value: post) {
                        Label("Comment", image: "comment-outline-20")
                            .body4LinkTypography()
                            .foregroundColor(Color("secondaryText"))
                    }
                    .buttonStyle(PostActionButtonStyle())
                }

                Button(action: {}) {
                    Label("Share", image: "share-outline-20")
                        .body4LinkTypography()
                        .foregroundColor(Color("secondaryText"))
                }
                .buttonStyle(PostActionButtonStyle())
            }
            .zIndex(3)
            .padding(.horizontal, -8)
            .padding(.top, -4)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(Color("surfaceBackground"))
        .fullScreenCover(item: $safariURL) { identifiableURL in
            SafariView(url: identifiableURL.url)
                .ignoresSafeArea()
        }
    }

    private var postHeader: some View {
        ZStack(alignment: .topLeading) {
            // Background area - links to post permalink
            if !isPermalink {
                NavigationLink(value: post) {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainNoHighlightButtonStyle())
            }

            // Foreground content
            HStack(alignment: .top) {
                PostHeaderContent(
                    post: post,
                    relationshipType: relationshipType,
                    disableProfileNavigation: disableProfileNavigation,
                    hideGroupInfo: hideGroupInfo
                )

                Spacer()
                    .allowsHitTesting(false)

                if !isPermalink {
                    HStack(spacing: 20) {
                        PostMenuView()
                        FDSIconButton(icon: "nav-cross", size: .size20, color: .secondary, action: {})
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func attachmentView(for attachment: PostAttachment) -> some View {
        switch attachment {
        case .image(let imageName):
            imageAttachment(imageName: imageName)

        case .link(let linkData):
            linkAttachment(data: linkData)
        }
    }

    private func imageAttachment(imageName: String) -> some View {
        HStack {
            if let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
        }
        .padding(.horizontal, -12)
    }

    @ViewBuilder
    private func linkAttachment(data: LinkAttachmentData) -> some View {
        Button {
            safariURL = URL(string: data.url).map { IdentifiableURL(url: $0) }
        } label: {
            VStack(alignment: .leading) {
                Image(data.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .clipped()
                VStack(alignment: .leading, spacing: 10) {
                    Text(data.domain)
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                    Text(data.title)
                        .headline4Typography()
                        .foregroundStyle(Color("primaryText"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
                .padding(.top, 2)
            }
            .background(Color("cardBackgroundFlat"))
        }
        .buttonStyle(FDSPressedState(cornerRadius: 0))
        .padding(.horizontal, -12)
    }
}

// MARK: - Post Action Button Style
private struct PostActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("nonMediaPressed"))
                    .opacity(configuration.isPressed ? 1.0 : 0.0)
            )
            .animation(.swapShuffleIn(MotionDuration.extraShortIn), value: configuration.isPressed)
    }
}

// MARK: - Plain No Highlight Button Style

private struct PlainNoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

// MARK: - Inline Reactions

struct InlineReactions: View {
    let reactions: [String]
    var body: some View {
        HStack(spacing: -2) {
            ForEach(reactions, id: \.self) { reaction in
                Image(reaction)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .zIndex(Double(reactions.count - reactions.firstIndex(of: reaction)!))
                    .padding(.horizontal, 1)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("surfaceBackground"), lineWidth: 2)
                    )
            }
        }
    }
}

// MARK: Post Menu Component

struct PostMenuView: View {
    var size: FDSIconButtonSize = .size20
    var color: FDSIconButtonColor = .secondary

    var body: some View {
        Menu {
            ControlGroup {
                Button {
                } label: {
                    Label("Show more", image: "arrow-up-circle-outline")
                }
                Button {
                } label: {
                    Label("Show less", image: "arrow-down-circle-outline")
                }
            }
            .controlGroupStyle(.menu)
            Button(action: {}) {
                Label("Save post", image: "bookmark-outline")
            }
            Button(action: {}) {
                Label("Hide post", image: "hide-outline")
            }
            Button(action: {}) {
                Label("Report post", image: "report-outline")
            }
            Button(action: {}) {
                Label("Why am I seeing this", image: "info-circle-outline")
            }
            Button(action: {}) {
                Text("Snooze for 30 days")
                Image("clock-outline")
            }
            Divider()
            Button(action: {}) {
                Label("Content preferences", image: "filter-sliders-outline")
            }
        } label: {
            FDSIconButton(icon: "dots-3-horizontal", size: size, color: color, action: {})
        }
        .tint(Color("primaryIcon"))
    }
}

// MARK: Story Data

struct StoryData: Hashable {
    var userName: String
    var storyImage: String // Cover image for tray
    var profileImage: String
    var segments: [String] // Multiple images/videos for the story
}

let storyData = [
    StoryData(userName: "Alice Smith", storyImage: "story1", profileImage: "profile3", segments: ["story1", "image1", "image2"]),
    StoryData(userName: "Bob Johnson", storyImage: "story2", profileImage: "profile2", segments: ["story2", "image3", "ocean"]),
    StoryData(userName: "Fatih Tekin", storyImage: "story3", profileImage: "profile9", segments: ["story3", "image4", "image5"]),
    StoryData(userName: "Diana Ross", storyImage: "story4", profileImage: "profile4", segments: ["story4", "image6"]),
    StoryData(userName: "Tina Wright", storyImage: "story5", profileImage: "profile6", segments: ["story5", "image7", "image8"]),
    StoryData(userName: "Kelsey Fung", storyImage: "story6", profileImage: "profile11", segments: ["story6", "jade1", "jade2"]),
    StoryData(userName: "Taina Thomsen", storyImage: "story7", profileImage: "profile7", segments: ["story7", "jade3", "jadesurfs"]),
    StoryData(userName: "Alex Kim", storyImage: "story8", profileImage: "profile5", segments: ["story8", "bandpractice1", "bandpractice2"]),
]

// MARK: Post Data

struct ActionChipData: Hashable {
    var label: String
    var iconName: String?
}

// MARK: - Post Attachments

enum PostAttachment: Hashable {
    case image(String)
    case link(LinkAttachmentData)
}

struct LinkAttachmentData: Hashable {
    var imageName: String
    var title: String
    var url: String

    var domain: String {
        guard let url = URL(string: url),
              let host = url.host else {
            return url
        }
        return host.replacingOccurrences(of: "www.", with: "")
    }
}

struct PostData: Hashable {
    var id: Int
    var userName: String
    var timeStamp: String
    var profileImage: String
    var attachment: PostAttachment?
    var text: String?
    var actionChips: [ActionChipData]?

    // Group post fields - if groupName exists, this is a group post
    var groupName: String?
    var groupImage: String?
}

let postData = [
    PostData(id: 1, userName: "Alice Smith", timeStamp: "2m", profileImage: "profile3", attachment: .image("image1"), text:"Spring brights, all sustainable vintage clothing! everything shown was made before 1982, except the 🌼", actionChips: nil),
    PostData(id: 2, userName: "Bob Johnson", timeStamp: "1h", profileImage: "profile2", attachment: nil, text: "just finished my morning coffee and already planning my next adventure. anyone else feel like the day has endless possibilities?", actionChips: nil),

    PostData(id: 13, userName: "John Stockholm", timeStamp: "45m", profileImage: "profile12", attachment: .image("bandpractice1"), text: "Thanks to everyone who joined last night—what a crowd! Still recovering from all the high notes.", actionChips: nil, groupName: "Karaoke Rockstars of Chicago", groupImage: "groupcover"),

    PostData(id: 3, userName: "Fatih Tekin", timeStamp: "19m", profileImage: "profile9", attachment: .image("image5"), text: "I love putting Eddie in a costume...gets me every time! 🐶", actionChips: [
        ActionChipData(label: "Are Corgis good dogs?", iconName: "fb-meta-ai-assistant"),
        ActionChipData(label: "Where are Corgis bred?", iconName: nil),
        ActionChipData(label: "Costume ideas for Corgis", iconName: nil),
        ActionChipData(label: "How much do Corgis weigh", iconName: nil)
    ]),
    PostData(id: 4, userName: "Diana Ross", timeStamp: "5m", profileImage: "profile4", attachment: nil, text: "Where can I find skate spots in SLC that are off the beaten path?", actionChips: nil),
    PostData(id: 5, userName: "Tina Wright", timeStamp: "20m", profileImage: "profile6", attachment: .image("image4"), text: "vibes on point", actionChips: nil),
    PostData(id: 6, userName: "Kelsey Fung", timeStamp: "4h", profileImage: "profile11", attachment: nil, text: "just got back from Diplo's Run Club. feeling so energized!", actionChips: nil),
    PostData(id: 7, userName: "Taina Thomsen", timeStamp: "2h", profileImage: "profile7", attachment: .link(LinkAttachmentData(imageName: "link-attachment", title: "Roberta's Pizza Dough Recipe - NYT Cooking", url: "https://cooking.nytimes.com/recipes/1016230-robertas-pizza-dough")), text:"y'all, THIS is the winning recipe. You don't need a stand mixer, either.", actionChips: nil),
    PostData(id: 8, userName: "Alex Kim", timeStamp: "10m", profileImage: "profile5", attachment: .image("image2"), text: "went to the competition. incredible energy!! if you feel stuck, go to one for serious motivation", actionChips: nil),
    PostData(id: 9, userName: "Sarah Chen", timeStamp: "30m", profileImage: "profile1", attachment: nil, text:"New design system just dropped at work! So excited to finally share what we've been working on ✨", actionChips: nil),
    PostData(id: 10, userName: "Sarah Chen", timeStamp: "30m", profileImage: "profile1", attachment: .image("product3"), text:"My little plant babies are growing so nicely 🌿", actionChips: nil),
    PostData(id: 11, userName: "Taina Thomsen", timeStamp: "12m", profileImage: "profile7", attachment: nil, text: "Just finished my morning run! Nothing beats that post-workout feeling 🏃‍♂️💪", actionChips: nil),
    PostData(id: 12, userName: "Jamie Lee", timeStamp: "25m", profileImage: "profile8", attachment: nil, text: "Anyone else obsessed with this new coffee shop downtown? Their oat milk latte is incredible ☕️", actionChips: nil),
]

// MARK: - Safari View

struct IdentifiableURL: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// Note: Replaced per-cell preference with scroll-based tracking (see onScrollGeometryChange above)

#Preview {
    HomeTab()
        .environmentObject(FDSTabBarHelper())
}
