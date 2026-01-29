import SwiftUI

// MARK: - Today's Snapshot Long Scroll View

struct TodaysSnapshotLongScrollView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabRouter: TabRouter
    @Namespace private var scrollNamespace
    @State private var showScrollToTopFAB = false
    @State private var scrollProxy: ScrollViewProxy?
    @State private var currentScrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                FDSNavigationBarCentered(
                    backAction: { dismiss() }
                )
                
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                // Header + Cards section with surface background
                                VStack(spacing: 0) {
                                    // Header section
                                    headerSection
                                    
                                    // Snapshot items card
                                    snapshotItemsCard(proxy: proxy)
                                }
                                .frame(width: geometry.size.width)
                                .background(Color("surfaceBackground"))
                                .id("highlights-section")
                                
                                // Visual separator
                                Rectangle()
                                    .fill(Color("wash"))
                                    .frame(height: 4)
                                    .frame(width: geometry.size.width)
                                
                                // Feed Units
                                feedUnits
                                    .frame(width: geometry.size.width)
                                
                                // End unit
                                endUnit
                                    .frame(width: geometry.size.width)
                            }
                        }
                        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                        .background(Color("surfaceBackground"))
                        .onScrollGeometryChange(for: CGFloat.self) { geometry in
                            geometry.contentOffset.y
                        } action: { oldValue, newValue in
                            currentScrollOffset = newValue
                            
                            // Show FAB when scroll position reaches 586
                            if newValue >= 586 && !showScrollToTopFAB {
                                withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                                    showScrollToTopFAB = true
                                }
                            }
                            // Hide FAB when scrolling back above 586
                            else if newValue < 586 && showScrollToTopFAB {
                                withAnimation(.swapShuffleOut(MotionDuration.shortOut)) {
                                    showScrollToTopFAB = false
                                }
                            }
                        }
                        .onAppear {
                            scrollProxy = proxy
                        }
                    }
                }
            }
            
            // Floating Action Button - Overlay (doesn't affect layout)
            if showScrollToTopFAB {
                ScrollToTopFAB {
                    withAnimation(.swapShuffleIn(MotionDuration.mediumIn)) {
                        scrollProxy?.scrollTo("highlights-section", anchor: .top)
                    }
                    // Hide FAB after scrolling back to top
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                            showScrollToTopFAB = false
                        }
                    }
                }
                .padding(.bottom, 20)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .hideFDSTabBar(true)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Promotion header chip
            HStack(spacing: 8) {
                Image("sunrise-outline")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color("primaryIcon"))
                
                Text("Today's snapshot")
                    .meta2Typography()
                    .foregroundStyle(Color("primaryText"))
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 12)
            
            // Main headline text
            Text("Explore interior design trends for 2026, learn how to set effective goals and check the powder days ahead.")
                .headline1EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
            
            // Meta text with 14px spacing from headline
            Text(formattedDate + " · Generated by AI")
                .meta3Typography()
                .foregroundStyle(Color("secondaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 14)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Snapshot Items Card
    
    private func snapshotItemsCard(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // Unit Header - "Highlights" inside the card
                FDSUnitHeader(
                    headlineText: "Highlights",
                    hierarchyLevel: .level3
                )
                
                ForEach(Array(longScrollSnapshotItems.enumerated()), id: \.element.id) { index, item in
                    LongScrollItemRow(item: item) {
                        // Show FAB when user taps down arrow
                        withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                            showScrollToTopFAB = true
                        }
                        // Scroll to the feed unit
                        withAnimation(.easeInOut(duration: 0.4)) {
                            proxy.scrollTo("feedUnit-\(index)", anchor: .top)
                        }
                    }
                    
                    if item.id != longScrollSnapshotItems.last?.id {
                        Divider()
                            .padding(.leading, 48)
                    }
                }
            }
            .background(Color("cardBackground"))
            .cornerRadius(8)
        }
        .padding(12)
        .background(Color("bottomSheetBackgroundDeemphasized"))
    }
    
    // MARK: - Feed Units
    
    private var feedUnits: some View {
        VStack(spacing: 4) {
            ForEach(Array(longScrollSnapshotItems.enumerated()), id: \.element.id) { index, item in
                LongScrollFeedUnit(item: item)
                    .id("feedUnit-\(index)")
            }
        }
        .padding(.vertical, 4)
        .background(Color("wash"))
    }
    
    // MARK: - End Unit
    
    private var endUnit: some View {
        VStack(spacing: 0) {
            Text("Nice job, you're all caught up today!\nSee you tomorrow.")
                .headline4Typography()
                .foregroundStyle(Color("primaryText"))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.bottom, 18)
                .padding(.horizontal, 12)
            
            FDSButton(
                type: .primaryDeemphasized,
                label: "Go to Feed",
                size: .medium,
                widthMode: .flexible,
                action: {
                    tabRouter.selection = .home
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

// MARK: - Long Scroll Item Row

struct LongScrollItemRow: View {
    let item: SnapshotItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Left emoji container
                SnapshotEmojiContainer(emoji: item.emoji, size: 32)
                
                // Text content - headline with embedded link
                buildHeadlineText(headline: item.headline, linkText: item.detailTitle)
                    .body3Typography()
                    .foregroundStyle(Color("primaryText"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Down arrow (scroll indicator)
                Image("arrow-down-outline")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color("secondaryIcon"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(FDSPressedState(cornerRadius: 0))
    }
    
    // Build text with highlighted link portion matching unit header
    private func buildHeadlineText(headline: String, linkText: String) -> Text {
        // Find the link text in the headline (case insensitive)
        guard let range = headline.range(of: linkText, options: .caseInsensitive) else {
            // If exact match not found, just return regular text
            return Text(headline)
        }
        
        let beforeLink = String(headline[..<range.lowerBound])
        let linkPortion = String(headline[range])
        let afterLink = String(headline[range.upperBound...])
        
        return Text(beforeLink)
            .foregroundColor(Color("primaryText")) +
        Text(linkPortion)
            .foregroundColor(Color("primaryText"))
            .fontWeight(.semibold) +
        Text(afterLink)
            .foregroundColor(Color("primaryText"))
    }
}

// MARK: - Long Scroll Feed Unit

struct LongScrollFeedUnit: View {
    let item: SnapshotItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. Unit Header - Title with menu (capitalize first letter for proper display)
            FDSUnitHeader(
                headlineText: item.detailTitle.capitalized,
                hierarchyLevel: .level3,
                rightAddOn: .iconButton(icon: "dots-3-horizontal-filled", action: {})
            )
            
            // 2. Summary paragraph
            Text(item.summaryParagraph)
                .body3Typography()
                .foregroundStyle(Color("primaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            
            // 3. Media - Full-width image (tappable to permalink) - 16:9 aspect ratio with crop
            if let firstPost = item.relatedPosts.first, let imageName = firstPost.imageName {
                NavigationLink {
                    SnapshotPermalinkView(post: firstPost, snapshotItem: item)
                } label: {
                    GeometryReader { geo in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.width / (16/9))
                            .clipped()
                    }
                    .aspectRatio(16/9, contentMode: .fit)
                }
                .buttonStyle(FDSPressedState(cornerRadius: 0))
            }
            
            // 4. Footer - Thumbs up/down icons
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image("hand-thumbs-up-outline")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color("primaryIcon"))
                }
                .buttonStyle(FDSPressedState(scale: .medium))
                
                Button(action: {}) {
                    Image("hand-thumbs-down-outline")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color("primaryIcon"))
                }
                .buttonStyle(FDSPressedState(scale: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color("surfaceBackground"))
    }
}

// MARK: - Long Scroll Bullet Text (Simple Text concatenation)

private struct LongScrollBulletText: View {
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
            // Add text before ** in primary text color
            let before = String(remaining[..<startRange.lowerBound])
            result = result + Text(before)
                .foregroundColor(Color("primaryText"))
            
            remaining = String(remaining[startRange.upperBound...])
            
            // Find closing **
            if let endRange = remaining.range(of: "**") {
                let highlighted = String(remaining[..<endRange.lowerBound])
                result = result + Text(highlighted)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("accentColor"))
                remaining = String(remaining[endRange.upperBound...])
            }
        }
        
        // Add remaining text in primary text color
        result = result + Text(remaining)
            .foregroundColor(Color("primaryText"))
        return result
    }
}

// MARK: - Long Scroll Bullet Text With Link

private struct LongScrollBulletTextWithLink: View {
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


// MARK: - Sample Data for Long Scroll

private let longScrollSnapshotItems: [SnapshotItem] = [
    SnapshotItem(
        emoji: "🛋️",
        headline: "See Interior Design Trends, including \"soft minimalism,\" with earthy tones and cozy curves.",
        meta: "Read the latest interior design trends",
        detailTitle: "Interior Design Trends",
        summaryParagraph: "Discover why warm neutral and earthy accents are replacing cool grays to create dreamy, high-vibe living spaces this year. Embrace the sophisticated grandma core aesthetic featuring layered patterns and vintage vibes. See why walnut finishes and monochromatic paints are in while 2010s fads are officially out for 2026.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "Architecture Digest",
                profileImage: "profileAD",
                isVerified: true,
                timeAgo: "3h",
                text: "As we look ahead to 2026, interior design is embracing warm neutrals and earthy accents. Think soft beiges, warm taupes, and muted greens that create a cozy atmosphere. Natural materials like wood and stone will be prominent, adding texture and warmth to spaces. Expect to see plants integrated into decor, bringing a touch of nature indoors. This trend not only promotes relaxation but also connects us to the environment, making our homes feel more inviting.",
                imageName: "interior1",
                likeCount: "442",
                commentCount: "155",
                shareCount: "12 shares",
                reactions: ["like", "love", "wow"]
            )
        ],
        profileImage: "profileAD",
        mediaItems: []
    ),
    SnapshotItem(
        emoji: "🎯",
        headline: "Master the SMART, DUMB and HARD goal frameworks to ensure your 2026 resolutions turn true.",
        meta: "Read the conversation here",
        detailTitle: "goal frameworks",
        summaryParagraph: "Learn why SMART goals (Specific, Measurable, Achievable, Relevant, Time-bound) remain the gold standard for professional growth. Discover the DUMB framework (Dream-driven, Uplifting, Method-friendly, Behavior-triggered) for passion projects. Explore HARD goals (Heartfelt, Animated, Required, Difficult) when you need breakthrough results.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "Productivity Hub",
                profileImage: "profile4",
                isVerified: true,
                timeAgo: "5h",
                text: "2026 is your year to achieve more. Here's how the best frameworks can help you set and crush your goals...",
                imageName: "image4",
                likeCount: "1.2K",
                commentCount: "89",
                shareCount: "45.2K",
                reactions: ["like", "love", "support"]
            )
        ],
        profileImage: "profile4",
        mediaItems: []
    ),
    SnapshotItem(
        emoji: "🎿",
        headline: "New forecast predicts a La Niña winter. For Tahoe skiers, this could mean more powder days ahead.",
        meta: "Check the full winter outlook",
        detailTitle: "La Niña winter",
        summaryParagraph: "La Niña conditions are expected to bring above-average snowfall to the Sierra Nevada through February. Lake Tahoe resorts could see 150-200% of normal snowpack based on current models. Best powder days likely in January and early February according to meteorologists.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "Tahoe Weather",
                profileImage: "profile5",
                isVerified: true,
                timeAgo: "2h",
                text: "Get ready for an epic season! La Niña is setting up perfectly for Tahoe...",
                imageName: "image5",
                likeCount: "3.4K",
                commentCount: "267",
                shareCount: "12.1K",
                reactions: ["like", "wow", "love"]
            )
        ],
        profileImage: "profile5",
        mediaItems: []
    ),
    SnapshotItem(
        emoji: "🍲",
        headline: "Simplify your evening with a one-pot chicken and potato bake flavored with fresh rosemary.",
        meta: "See easy recipes for tonight",
        detailTitle: "one-pot chicken",
        summaryParagraph: "One-pot chicken and potato bake takes just 10 minutes to prep with ingredients you likely have. Fresh rosemary and garlic create restaurant-quality flavor without the fuss. Perfect for meal prep – leftovers taste even better the next day.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "Home Chef",
                profileImage: "profile6",
                isVerified: true,
                timeAgo: "4h",
                text: "This one-pot wonder has become our family's new favorite. Ready in under 45 minutes!",
                imageName: "image6",
                likeCount: "892",
                commentCount: "156",
                shareCount: "23.4K",
                reactions: ["love", "like", "wow"]
            )
        ],
        profileImage: "profile6",
        mediaItems: []
    ),
    SnapshotItem(
        emoji: "🥾",
        headline: "California Adventures. Hike through a stunning desert lava field, walk through a 1300ft lava tube and more.",
        meta: "Explore California volcanic adventures",
        detailTitle: "California Adventures",
        summaryParagraph: "Explore Lava Beds National Monument with over 700 caves and stunning volcanic landscapes. Walk through the 1300ft Mushpot Cave – one of the most accessible lava tubes in the state. Discover Captain Jack's Stronghold and the fascinating history of the Modoc War.",
        relatedPosts: [
            SnapshotPostData(
                authorName: "California Adventures",
                profileImage: "profile7",
                isVerified: true,
                timeAgo: "6h",
                text: "Northern California's hidden gem! These volcanic landscapes will blow your mind...",
                imageName: "image7",
                likeCount: "2.1K",
                commentCount: "198",
                shareCount: "8.7K",
                reactions: ["wow", "love", "like"]
            )
        ],
        profileImage: "profile7",
        mediaItems: []
    )
]

// MARK: - Scroll to Top FAB

struct ScrollToTopFAB: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image("arrow-up-outline")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color("primaryIcon"))
                .padding(12)
                .background(
                    Circle()
                        .fill(Color("surfaceBackground"))
                )
                .persistentUIShadow(cornerRadius: 100)
        }
        .buttonStyle(FDSPressedState(circle: true, scale: .medium))
    }
}

#Preview {
    NavigationStack {
        TodaysSnapshotLongScrollView()
    }
    .environmentObject(FDSTabBarHelper())
}

