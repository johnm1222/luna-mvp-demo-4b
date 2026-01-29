import SwiftUI

// MARK: - Today's Snapshot View v2

struct TodaysSnapshotView_v2: View {
    @Environment(\.dismiss) private var dismiss
    @Namespace private var scrollNamespace
    @State private var hasSnappedToFeed = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showFAB = true // Track FAB visibility
    @State private var showScrollToTopFAB = false // Track scroll-to-top FAB visibility
    @State private var shouldScrollToFeed = false // Trigger scroll action
    @State private var shouldScrollToTop = false // Trigger scroll to top action
    
    private let snapThreshold: CGFloat = 50 // Scroll distance before snapping
    private let fabHideThreshold: CGFloat = 10 // Hide FAB after scrolling 10px
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                FDSNavigationBarCentered(
                    backAction: { dismiss() }
                )
                .shadow(color: showScrollToTopFAB ? Color.black.opacity(0.1) : Color.clear, radius: 1, x: 0, y: 1)
                
                GeometryReader { geometry in
                    ZStack {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    // LANDING SCREEN: Header + Snapshot Cards + Down Button
                                    // This section fills the full screen height (932pt) so feed units are below the fold
                                    VStack(spacing: 0) {
                                        // Header section (white background)
                                        headerSection
                                            .background(Color("surfaceBackground"))
                                        
                                        // Card section with grey background
                                        VStack(spacing: 0) {
                                            // Snapshot items card
                                            snapshotItemsCard(proxy: proxy)
                                            
                                            // 16px spacer below list cell table
                                            Color.clear
                                                .frame(height: 16)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .top)
                                    }
                                    .frame(width: geometry.size.width)
                                    .background(Color("bottomSheetBackgroundDeemphasized"))
                                    .clipped()
                                    .id("landingScreen")
                                    .background(
                                        GeometryReader { scrollGeo in
                                            Color.clear
                                                .onAppear {
                                                    scrollOffset = scrollGeo.frame(in: .global).minY
                                                }
                                                .onChange(of: scrollGeo.frame(in: .global).minY) { oldValue, newValue in
                                                    scrollOffset = newValue
                                                    
                                                    // Hide down FAB when scrolled down, show up FAB
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        showFAB = newValue > -fabHideThreshold
                                                        showScrollToTopFAB = newValue <= -fabHideThreshold
                                                    }
                                                    
                                                    // Snap to first feed unit when user scrolls past threshold
                                                    if !hasSnappedToFeed && newValue < -snapThreshold {
                                                        hasSnappedToFeed = true
                                                        withAnimation(.easeInOut(duration: 0.4)) {
                                                            proxy.scrollTo("feedUnit-0", anchor: UnitPoint.top)
                                                        }
                                                    }
                                                }
                                        }
                                    )
                                    
                                    // BELOW THE FOLD: Feed Units with media
                                    VStack(spacing: 0) {
                                        ForEach(Array(cleanScrollSnapshotItems.enumerated()), id: \.element.id) { index, item in
                                            CleanScrollFeedUnit_v2(item: item)
                                                .frame(width: max(0, geometry.size.width))
                                                .id("feedUnit-\(index)")
                                            
                                            // 4px divider between feed units
                                            if index < cleanScrollSnapshotItems.count - 1 {
                                                Color("wash")
                                                    .frame(height: 4)
                                            }
                                        }
                                        
                                    // 4px divider before topics unit
                                    Color("wash")
                                        .frame(height: 4)
                                }
                                
                                // Topics suggestion unit
                                topicsUnit
                                    .frame(width: max(0, geometry.size.width))
                                
                                // 4px divider before end unit
                                Color("wash")
                                    .frame(height: 4)
                                
                                // End unit
                                endUnit
                                    .frame(width: max(0, geometry.size.width))
                                }
                            }
                            .background(Color("surfaceBackground"))
                            .onChange(of: shouldScrollToFeed) { oldValue, newValue in
                                if newValue {
                                    hasSnappedToFeed = true
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        proxy.scrollTo("feedUnit-0", anchor: UnitPoint.top)
                                    }
                                    shouldScrollToFeed = false
                                }
                            }
                            .onChange(of: shouldScrollToTop) { oldValue, newValue in
                                if newValue {
                                    // Reset snap flag immediately so we can scroll back
                                    hasSnappedToFeed = false
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        proxy.scrollTo("landingScreen", anchor: .top)
                                    }
                                    shouldScrollToTop = false
                                }
                            }
                        }
                    }
                }
            }
            
            // Floating Action Button positioned at bottom of viewport (hidden when scrolling)
            if showFAB {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        shouldScrollToFeed = true
                    }) {
                        HStack(spacing: 6) {
                            Image("arrow-down-filled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(Color("accentColor"))
                            
                            Text("Explore Today's snapshot")
                                .font(.body3)
                                .foregroundStyle(Color("accentColor"))
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(Color("secondaryButtonBackground"))
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 0)
                }
            }
            
            // Scroll to Top FAB (appears when scrolled down)
            if showScrollToTopFAB {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        shouldScrollToTop = true
                    }) {
                        Image("arrow-up-filled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color("accentColor"))
                            .padding(8)
                            .frame(width: 32, height: 32)
                            .background(Color("secondaryButtonBackground"))
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 0)
                }
            }
            
            // White overlay mask at bottom to prevent peeking
            // Debug: Scroll position indicator (hidden)
            // Uncomment below to show debug info
            /*
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Y: \(Int(scrollOffset))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Text("FAB: \(showFAB ? "visible" : "hidden")")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding(.trailing, 12)
                    .padding(.top, 60)
                }
                Spacer()
            }
            */
        }
        .hideFDSTabBar(true)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title section
            VStack(alignment: .leading, spacing: 0) {
                Text("Today's snapshot")
                    .headline1EmphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(formattedDate + " · Generated by AI")
                    .meta2Typography()
                    .foregroundStyle(Color("secondaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 20)
            
            // Action chips row
            HStack(spacing: 8) {
                // Weather chip with menu
                FDSActionChip(
                    size: .medium,
                    label: "☀️72° Palo Alto",
                    isMenu: true,
                    action: {}
                )
                
                // Listen chip
                FDSActionChip(
                    size: .medium,
                    label: "5:30 listen",
                    leftAddOn: .icon("play-outline"),
                    action: {}
                )
                
                // Ask AI chip
                FDSActionChip(
                    size: .medium,
                    label: "Ask AI",
                    leftAddOn: .icon("gen-ai-star-filled"),
                    action: {}
                )
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Snapshot Items Card (using Push View 1:1 style)
    
    private func snapshotItemsCard(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // Unit Header - "Highlights" inside the card
                FDSUnitHeader(
                    headlineText: "Highlights",
                    hierarchyLevel: .level3
                )
                
                ForEach(Array(cleanScrollSnapshotItems.enumerated()), id: \.element.id) { index, item in
                    CleanScrollItemRow_v2(item: item) {
                        // Scroll to the corresponding feed unit
                        withAnimation(.easeInOut(duration: 0.4)) {
                            proxy.scrollTo("feedUnit-\(index)", anchor: .top)
                        }
                    }
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            .background(Color("cardBackground"))
            .cornerRadius(8)
        }
        .padding(.horizontal, 12)
        .padding(.top, 16)
        .background(Color("bottomSheetBackgroundDeemphasized"))
    }
    
    // MARK: - Topics Unit
    
    private var topicsUnit: some View {
        VStack(spacing: 0) {
            // Unit Header with menu
            HStack(spacing: 0) {
                Text("Show more of these topics")
                    .headline4Typography()
                    .foregroundStyle(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Menu button
                FDSIconButton(
                    icon: "dots-3-horizontal-filled",
                    size: .size20,
                    action: {}
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 4)
            
            // Action chips - centered
            HStack(spacing: 8) {
                FDSActionChip(
                    size: .medium,
                    label: "Grammys",
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "Robotaxis",
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "Add a topic",
                    leftAddOn: .icon("plus-filled"),
                    action: {}
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(Color("surfaceBackground"))
    }
    
    // MARK: - End Unit
    
    private var endUnit: some View {
        VStack(spacing: 0) {
            // Completion message
            Text("Nice job, you're all caught up today!\nSee you tomorrow.")
                .headline4Typography()
                .foregroundStyle(Color("primaryText"))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.bottom, 18)
                .padding(.horizontal, 12)
            
            // Go to Feed button
            FDSButton(
                type: .primaryDeemphasized,
                label: "Go to Feed",
                size: .medium,
                widthMode: .flexible,
                action: {
                    dismiss()
                }
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color("surfaceBackground"))
    }
    
    // MARK: - Helpers
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Clean Scroll Item Row (scrolls to feed unit, no arrows)

private struct CleanScrollItemRow_v2: View {
    let item: SnapshotItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Text content - title (bold) + body text
                VStack(alignment: .leading, spacing: 0) {
                    buildText(title: item.detailTitle, body: item.headline)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right profile photo - 32px size with 25% rounded edge
                Image(item.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(FDSPressedState(cornerRadius: 0))
    }
    
    // Build text with bold title + regular body - Typography applied to each part
    private func buildText(title: String, body: String) -> Text {
        let titleText = Text(title)
            .font(.body3)
            .fontWeight(.semibold)
            .foregroundColor(Color("primaryText"))
            .kerning(-0.24)
        
        let spaceText = Text(" ")
            .font(.body3)
            .foregroundColor(Color("primaryText"))
            .kerning(-0.24)
        
        let bodyText = Text(body)
            .font(.body3)
            .fontWeight(.regular)
            .foregroundColor(Color("primaryText"))
            .kerning(-0.24)
        
        return titleText + spaceText + bodyText
    }
}

// MARK: - Clean Scroll Feed Unit (Detail Card Design)

private struct CleanScrollFeedUnit_v2: View {
    let item: SnapshotItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. Header - Emoji + Title with menu
            HStack(spacing: 0) {
                // Emoji container
                SnapshotEmojiContainer(emoji: item.emoji, size: 32)
                    .padding(.trailing, 8)
                
                // Title
                Text(item.detailTitle)
                    .headline3Typography()
                    .foregroundStyle(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Menu button
                FDSIconButton(
                    icon: "dots-3-horizontal-filled",
                    size: .size20,
                    action: {}
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 12)
            
            // 2. Summary paragraph
            Text(item.summaryParagraph)
                .body3Typography()
                .foregroundStyle(Color("primaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            
            // 3. Sources action chip
            FDSActionChip(
                size: .medium,
                label: "Sources",
                action: {}
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 20)
            
            // 4. "More about this" headline
            Text("More about this")
                .headline4Typography()
                .foregroundStyle(Color("primaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            
            // 5. Horizontal scroll with variable width media
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(item.relatedPosts.enumerated()), id: \.element.id) { index, post in
                        if let imageName = post.imageName {
                            FeedMediaCard(
                                imageName: imageName,
                                aspectRatio: getFeedAspectRatio(for: index)
                            )
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 16)
            
            // 6. Thumbs up/down
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
    
    private func getFeedAspectRatio(for index: Int) -> FeedMediaAspectRatio {
        // Cycle through: 9:16, 16:9, 1:1
        let ratios: [FeedMediaAspectRatio] = [.portrait, .landscape, .square]
        return ratios[index % ratios.count]
    }
}

// MARK: - Feed Media Card

private struct FeedMediaCard: View {
    let imageName: String
    let aspectRatio: FeedMediaAspectRatio
    
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

private enum FeedMediaAspectRatio {
    case portrait  // 9:16
    case landscape // 16:9
    case square    // 1:1
    
    var width: CGFloat {
        switch self {
        case .portrait: return 101  // 9:16 ratio with height 180
        case .landscape: return 320 // 16:9 ratio with height 180
        case .square: return 180    // 1:1 ratio with height 180
        }
    }
    
    var height: CGFloat {
        return 180  // All media cards are 180pt tall
    }
}

// MARK: - Clean Scroll Bullet Text

private struct CleanScrollBulletText: View {
    let text: String
    
    var body: some View {
        buildText()
            .body3Typography()
            .foregroundStyle(Color("primaryText"))
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private func buildText() -> Text {
        var result = Text("")
        var remaining = text
        
        while let startRange = remaining.range(of: "**") {
            let before = String(remaining[..<startRange.lowerBound])
            result = result + Text(before)
                .foregroundColor(Color("primaryText"))
            
            remaining = String(remaining[startRange.upperBound...])
            
            if let endRange = remaining.range(of: "**") {
                let highlighted = String(remaining[..<endRange.lowerBound])
                result = result + Text(highlighted)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("accentColor"))
                remaining = String(remaining[endRange.upperBound...])
            }
        }
        
        result = result + Text(remaining)
            .foregroundColor(Color("primaryText"))
        return result
    }
}

// MARK: - Clean Scroll Bullet Text With Link

private struct CleanScrollBulletTextWithLink: View {
    let text: String
    let post: SnapshotPostData
    let item: SnapshotItem
    
    var body: some View {
        NavigationLink {
            SnapshotPermalinkView(post: post, snapshotItem: item)
        } label: {
            buildText()
                .body3Typography()
                .foregroundStyle(Color("primaryText"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
    }
    
    private func buildText() -> Text {
        var result = Text("")
        var remaining = text
        
        while let startRange = remaining.range(of: "**") {
            let before = String(remaining[..<startRange.lowerBound])
            result = result + Text(before)
                .foregroundColor(Color("primaryText"))
            
            remaining = String(remaining[startRange.upperBound...])
            
            if let endRange = remaining.range(of: "**") {
                let highlighted = String(remaining[..<endRange.lowerBound])
                result = result + Text(highlighted)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("accentColor"))
                remaining = String(remaining[endRange.upperBound...])
            }
        }
        
        result = result + Text(remaining)
            .foregroundColor(Color("primaryText"))
        return result
    }
}

// MARK: - Sample Data for Clean Scroll

private let cleanScrollSnapshotItems: [SnapshotItem] = [
    SnapshotItem(
        emoji: "🎨",
        headline: "for 2026, Cloud Dancer, emphasizes connection, adaptability, and optimism.",
        meta: "Read about Pantone's Color of the Year",
        detailTitle: "Pantone's Color of the Year",
        summaryParagraph: "Cloud Dancer reflects a broader shift toward softer, more grounding aesthetics amid cultural and economic uncertainty. Chosen by Pantone's color experts, the tone is intended to resonate across fashion, interiors, branding, and digital design. Early reactions from designers suggest the color may replace recent bold palettes with more restrained, calming expressions.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "Pantone Color Institute",
                profileImage: "profileAD",
                isVerified: true,
                timeAgo: "2h",
                text: "Introducing Cloud Dancer, the 2026 Color of the Year. This versatile shade embodies connection, adaptability, and optimism.",
                imageName: "pantone_1",
                likeCount: "5.2K",
                commentCount: "342",
                shareCount: "1.8K",
                reactions: ["like", "love", "wow"]
            ),
            SnapshotPostData(
                authorName: "Pantone Color Institute",
                profileImage: "profileAD",
                isVerified: true,
                timeAgo: "2h",
                text: "Cloud Dancer details",
                imageName: "pantone_2",
                likeCount: "5.2K",
                commentCount: "342",
                shareCount: "1.8K",
                reactions: ["like", "love", "wow"]
            ),
            SnapshotPostData(
                authorName: "Pantone Color Institute",
                profileImage: "profileAD",
                isVerified: true,
                timeAgo: "2h",
                text: "Cloud Dancer in fashion",
                imageName: "pantone_3",
                likeCount: "5.2K",
                commentCount: "342",
                shareCount: "1.8K",
                reactions: ["like", "love", "wow"]
            )
        ],
        profileImage: "pantone_1",
        mediaItems: [
            MediaItem(imageName: "pantone_1", aspectRatio: .portrait),
            MediaItem(imageName: "pantone_2", aspectRatio: .landscape),
            MediaItem(imageName: "pantone_3", aspectRatio: .square)
        ]
    ),
    SnapshotItem(
        emoji: "🏀",
        headline: "holds despite missed games, keeping league-wide debate intense through the midseason stretch.",
        meta: "Follow the MVP race",
        detailTitle: "Jokic MVP race lead",
        summaryParagraph: "Even with limited availability during brief injury absences, Jokic's overall impact continues to separate him from other contenders. His efficiency, playmaking, and on-court control remain central to Denver's success, reinforcing his value beyond raw scoring totals. Analysts point to his consistency and ability to elevate teammates as defining factors in the race.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "ESPN NBA",
                profileImage: "profile3",
                isVerified: true,
                timeAgo: "3h",
                text: "Jokic's MVP case remains strong despite missing games. Is he still the favorite?",
                imageName: "jokic_1",
                likeCount: "3.1K",
                commentCount: "892",
                shareCount: "520",
                reactions: ["like", "wow", "love"]
            ),
            SnapshotPostData(
                authorName: "ESPN NBA",
                profileImage: "profile3",
                isVerified: true,
                timeAgo: "3h",
                text: "Jokic highlights",
                imageName: "jokic_2",
                likeCount: "3.1K",
                commentCount: "892",
                shareCount: "520",
                reactions: ["like", "wow", "love"]
            ),
            SnapshotPostData(
                authorName: "ESPN NBA",
                profileImage: "profile3",
                isVerified: true,
                timeAgo: "3h",
                text: "Jokic stats breakdown",
                imageName: "jokic_3",
                likeCount: "3.1K",
                commentCount: "892",
                shareCount: "520",
                reactions: ["like", "wow", "love"]
            )
        ],
        profileImage: "jokic_1",
        mediaItems: [
            MediaItem(imageName: "jokic_1", aspectRatio: .portrait),
            MediaItem(imageName: "jokic_2", aspectRatio: .landscape),
            MediaItem(imageName: "jokic_3", aspectRatio: .square)
        ]
    ),
    SnapshotItem(
        emoji: "❄️",
        headline: "expansion adds new hands-on activities for toddlers and young children.",
        meta: "Learn about new programs",
        detailTitle: "Children Museum Winter Programs",
        summaryParagraph: "New program focused on movement, sensory play, and early learning experiences designed for colder months. Sessions are structured with shorter time blocks and caregiver-friendly pacing, making them accessible for younger age groups. Registration is now open.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "Children's Museum",
                profileImage: "profile4",
                isVerified: true,
                timeAgo: "5h",
                text: "Exciting news! Our winter programs are expanding with new activities for your little ones.",
                imageName: "winter1",
                likeCount: "892",
                commentCount: "124",
                shareCount: "310",
                reactions: ["love", "like", "support"]
            ),
            SnapshotPostData(
                authorName: "Children's Museum",
                profileImage: "profile4",
                isVerified: true,
                timeAgo: "5h",
                text: "Winter activities for kids",
                imageName: "winter2",
                likeCount: "892",
                commentCount: "124",
                shareCount: "310",
                reactions: ["love", "like", "support"]
            ),
            SnapshotPostData(
                authorName: "Children's Museum",
                profileImage: "profile4",
                isVerified: true,
                timeAgo: "5h",
                text: "Hands-on learning",
                imageName: "winter3",
                likeCount: "892",
                commentCount: "124",
                shareCount: "310",
                reactions: ["love", "like", "support"]
            )
        ],
        profileImage: "winter1",
        mediaItems: [
            MediaItem(imageName: "winter1", aspectRatio: .portrait),
            MediaItem(imageName: "winter2", aspectRatio: .landscape),
            MediaItem(imageName: "winter3", aspectRatio: .square)
        ]
    ),
    SnapshotItem(
        emoji: "🥣",
        headline: "can be easily upgraded using simple pantry additions recommended by dietitians.",
        meta: "Get healthy snack ideas",
        detailTitle: "High Protein Toddler Snacks",
        summaryParagraph: "Nutrition experts suggest adding ingredients like hemp hearts, peanut butter, or cottage cheese to familiar snacks. These additions help support healthy growth without requiring complex meal prep. Hemp hearts are especially notable as a complete protein, containing all nine essential amino acids.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "Nutrition for Kids",
                profileImage: "profile5",
                isVerified: true,
                timeAgo: "4h",
                text: "Easy ways to add more protein to your toddler's snacks without the fuss!",
                imageName: "ffmeal_1",
                likeCount: "1.5K",
                commentCount: "203",
                shareCount: "680",
                reactions: ["love", "like", "wow"]
            ),
            SnapshotPostData(
                authorName: "Nutrition for Kids",
                profileImage: "profile5",
                isVerified: true,
                timeAgo: "4h",
                text: "Healthy toddler meals",
                imageName: "ffmeal_2",
                likeCount: "1.5K",
                commentCount: "203",
                shareCount: "680",
                reactions: ["love", "like", "wow"]
            ),
            SnapshotPostData(
                authorName: "Nutrition for Kids",
                profileImage: "profile5",
                isVerified: true,
                timeAgo: "4h",
                text: "Protein-packed snacks",
                imageName: "ffmeal_3",
                likeCount: "1.5K",
                commentCount: "203",
                shareCount: "680",
                reactions: ["love", "like", "wow"]
            )
        ],
        profileImage: "ffmeal_1",
        mediaItems: [
            MediaItem(imageName: "ffmeal_1", aspectRatio: .portrait),
            MediaItem(imageName: "ffmeal_2", aspectRatio: .landscape),
            MediaItem(imageName: "ffmeal_3", aspectRatio: .square)
        ]
    ),
    SnapshotItem(
        emoji: "🍽️",
        headline: "were announced, featuring prix-fixe menus at 300+ restaurants.",
        meta: "View participating restaurants",
        detailTitle: "Denver Restaurant Week Dates",
        summaryParagraph: "The annual event features multi-course menus at set price tiers, giving diners a chance to try new restaurants at a lower cost. Participating spots span downtown, RiNo, LoHi, and neighborhood corridors across the metro area. Reservations tend to book early for higher-profile restaurants, while weekday lunches and early seatings are often easier to secure. Diners are encouraged to check menus in advance, as offerings and pricing vary by location.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "Visit Denver",
                profileImage: "profile6",
                isVerified: true,
                timeAgo: "6h",
                text: "Save the date! Denver Restaurant Week is back with incredible deals at 300+ restaurants.",
                imageName: "denver1",
                likeCount: "2.3K",
                commentCount: "156",
                shareCount: "920",
                reactions: ["like", "love", "yum"]
            ),
            SnapshotPostData(
                authorName: "Visit Denver",
                profileImage: "profile6",
                isVerified: true,
                timeAgo: "6h",
                text: "Denver dining experiences",
                imageName: "denver2",
                likeCount: "2.3K",
                commentCount: "156",
                shareCount: "920",
                reactions: ["like", "love", "yum"]
            ),
            SnapshotPostData(
                authorName: "Visit Denver",
                profileImage: "profile6",
                isVerified: true,
                timeAgo: "6h",
                text: "Restaurant Week highlights",
                imageName: "denver3",
                likeCount: "2.3K",
                commentCount: "156",
                shareCount: "920",
                reactions: ["like", "love", "yum"]
            )
        ],
        profileImage: "denver1",
        mediaItems: [
            MediaItem(imageName: "denver1", aspectRatio: .portrait),
            MediaItem(imageName: "denver2", aspectRatio: .landscape),
            MediaItem(imageName: "denver3", aspectRatio: .square)
        ]
    )
]

#Preview {
    NavigationStack {
        TodaysSnapshotView_v2()
    }
    .environmentObject(FDSTabBarHelper())
}


